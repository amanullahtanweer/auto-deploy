class AppDeployJob < ApplicationJob
  queue_as :default

  def perform(app)
  	@app = app

    begin 
    Net::SSH.start(app.server.public_ip, 'deploy', :timeout => 10, :number_of_password_prompts => 0) do | ssh |

      ssh.exec!("mkdir ~/.autodeploy")

      @repo_script = Script.find_by_name('repo-clone').body
      @deploy_script = Script.find_by_name('deploy').body

      unless app.clone_status?
        ssh.exec!("cat <<'EOF' > ~/.autodeploy/repo-clone.sh 
#{@repo_script}
EOF")
        action_notify( {html: "Uploaded ~/.autodeploy/repo-clone.sh \n"} )

        ssh.exec!("sed -i -e 's/\r$//' ~/.autodeploy/repo-clone.sh")

        ssh.exec!("sh ~/.autodeploy/repo-clone.sh #{app.name} #{app.repo_url} | tee -a ~/.autodeploy/repo-clone.log") do |channel, stream, data|
          action_notify( {html: "#{data} \n"} )
        end
        app.clone_status = 1
        app.save
      end

      # Database Deploy as root
      Net::SSH.start(app.server.public_ip, 'root', :timeout => 30, :number_of_password_prompts => 0) do | ssh |

        unless app.pg_status?
          @db_script = Script.find_by_name('db').body
          ssh.exec!("cat <<'EOF' > ~/.autodeploy/pg-deploy.sh 
#{@db_script}
EOF")
          ssh.exec!("sed -i -e 's/\r$//' ~/.autodeploy/pg-deploy.sh")
          db_user = 20.times.collect{[*'a'..'z'].sample}.join
          db_password = 20.times.collect{[*'a'..'z'].sample}.join
          db_name = app.name

          app.env_vars = {:"DBATABASE_URL" => "postgresql://#{db_user}:#{db_password}@localhost/#{db_name}"}
          action_notify( {html: "#{app.env_vars} \n"} )

          ssh.exec!("sh ~/.autodeploy/pg-deploy.sh #{db_user} #{db_password} #{db_name} | tee -a ~/.autodeploy/pg-deploy.log") do |channel, stream, data|
            action_notify( {html: "#{data} \n"} )
          end
          app.pg_status = 1

          if app.save
            action_notify( {html: "<b style='color: green'>Database created Successfull..!</b> \n"} )
          end
        end
      end


      ssh.exec!("cat <<'EOF' > ~/.autodeploy/app-deploy.sh 
#{@deploy_script}
EOF")
      ssh.exec!("sed -i -e 's/\r$//' ~/.autodeploy/app-deploy.sh")

      ssh.exec!("cat << 'EOF' > ~/#{app.name}/.rbenv-vars
DATABASE_URL=#{app.env_vars.values.first}
RACK_ENV=production
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=enabled
RAILS_SERVE_STATIC_FILES=enabled
SECRET_KEY_BASE=22f9227cdbf6d88926a5b56e333c17debf279205bd99580c76f04de4f6e5421e282ce84909f322913df7a0b7ad604c2afe178826c6dbfce4ab4b72b8954e116e
EOF")
      ssh.exec!("sh ~/.autodeploy/app-deploy.sh #{app.name} #{app.branch} | tee -a ~/.autodeploy/app-deploy.log") do |channel, stream, data|
        action_notify( {html: "#{data} \n"} )
      end

      # Database Deploy as root
      Net::SSH.start(app.server.public_ip, 'root', :timeout => 30, :number_of_password_prompts => 0) do | ssh |

          ssh.exec!("cat <<'EOF' > /etc/nginx/sites-enabled/#{app.name}
server {
    listen       80;
    server_name  www.#{app.domain};
    return       301 https://#{app.domain}$request_uri;
}
server {
  listen 80;
  listen [::]:80;

  server_name #{app.domain || '_'};

  passenger_enabled on;
  rails_env    production;
  root         /home/deploy/#{app.name}/current/public;

  # Allow uploads up to 100MB in size
  client_max_body_size 100m;

  location /cable {
    passenger_app_group_name #{app.name}_websocket;
    passenger_force_max_concurrent_requests_per_process 0;
  }

  # redirect server error pages to the static page /50x.html
  error_page   500 502 503 504  /50x.html;
  location = /50x.html {
      root   html;
  }
}

EOF")


        if app.nginx_ssl
          ssh.exec!("/root/letsencrypt/letsencrypt-auto certonly --webroot --webroot-path /home/deploy/#{app.name}/current/public --renew-by-default --email aman@intellecta.co --text --agree-tos -d #{app.domain} -d www.#{app.domain}") do |channel, stream, data|

            action_notify( {html: "#{data} \n"} )
          end
          ssh.exec!("cat <<'EOF' > /etc/nginx/sites-enabled/#{app.name}
server {
    listen       80;
    server_name  www.#{app.domain};
    return       301 https://#{app.domain}$request_uri;
}

server {
  listen 80;
  listen [::]:80;

  server_name #{app.domain || '_'};

  passenger_enabled on;
  rails_env    production;
  root         /home/deploy/#{app.name}/current/public;

  # Allow uploads up to 100MB in size
  client_max_body_size 100m;

  location /cable {
    passenger_app_group_name #{app.name}_websocket;
    passenger_force_max_concurrent_requests_per_process 0;
  }

  # redirect server error pages to the static page /50x.html
  error_page   500 502 503 504  /50x.html;
  location = /50x.html {
      root   html;
  }
  listen 443 ssl; # managed by Certbot
  ssl_certificate /etc/letsencrypt/live/#{app.domain}/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/#{app.domain}/privkey.pem; # managed by Certbot
   include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    
   if ($scheme != 'https') {
       return 301 https://$host$request_uri;
   } # managed by Certbot

   if ($host = 'www.#{app.domain}') {
    return 301 https://#{app.domain}$request_uri;
   }
}

EOF")
        end


      ssh.exec("service nginx reload")
        action_notify( {html: "<b style='color: green'>Nginx config uploaded..!</b> \n"} )

      end


    end
    rescue => e
    	# SSH Connection fail
      action_notify( {html: "<span style='color: red'>Connection Fail!</span> \n", success: false} )
      action_notify( {html: "#{e} \n", success: false} )

    end

  end


  private

  def action_notify(data)
  	ActionCable.server.broadcast "app:#{@app.id}", data
  end

end
