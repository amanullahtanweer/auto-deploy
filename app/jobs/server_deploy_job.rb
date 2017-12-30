class ServerDeployJob < ApplicationJob
	queue_as :default

	def perform(server)
		@server = server
		config_dir = "~/.autodeploy/"
		begin 
			Net::SSH.start(server.public_ip, 'root', :timeout => 10, :number_of_password_prompts => 0) do | ssh |

				# Testing connection
				output = ssh.exec!("ls -lah")
				action_notify( {html: "#{output} \n"} )
				action_notify( {html: "<b style='color: green'>Connection Successfull..!</b> \n"} )

				# Updating Os
				# ssh.exec!("apt-get -y update") do |channel, stream, data|
				# 	ActionCable.server.broadcast 'scripts:1', 
				# 	action_notify( {html: data} )
				# end

				# Creating deploy user
				deploy_user = ssh.exec!("adduser --disabled-password --gecos '' deploy")
				ssh.exec!("usermod -aG sudo deploy")

				action_notify( {html: "#{deploy_user} \n"} )
				action_notify( {html: "<b style='color: green'>Deploy user created..!</b> \n"} )

				ssh.exec!("mkdir -p /home/deploy/.ssh")
				ssh.exec!("cp /root/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys")
				ssh.exec!("chown -R deploy:deploy /home/deploy/.ssh")

				action_notify( {html: "yes | cp -rf /root/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys \n"} )
				action_notify( {html: "chown -R deploy:deploy /home/deploy/.ssh \n"} )

				# Create required directories
				create_directory = ssh.exec!("mkdir .autodeploy && chmod +x .autodeploy")
				action_notify( {html: "#{create_directory} \n"} )


				# Creating setup script
				@setup_script = Script.find_by_name("server-setup").body
				@rbenv_script = Script.find_by_name("rbenv").body

				ssh.exec!("cat <<'EOF' > ~/.autodeploy/deploy.sh 
#{@setup_script}
EOF")
				action_notify( {html: "Uploaded ~/.autodeploy/deploy.sh \n" } )

				# Making script executable
				# ssh.exec!("chmod +x ~/.autodeploy/#{self.job_id}.sh")

				ssh.exec!("sed -i -e 's/\r$//' ~/.autodeploy/deploy.sh")


				ssh.exec!("sh ~/.autodeploy/deploy.sh | tee -a ~/.autodeploy/deploy.log") do |channel, stream, data|
					action_notify( {html: "#{data} \n"} )
				end

				# server.update_attribute(:is_active,false)

				ssh.exec!("rm /etc/nginx/sites-enabled/default")
			end

		rescue => e
			# SSH Connection fail
			action_notify( {html: "<span style='color: red'>Server Setup Fail!</span> \n", success: false })
			action_notify( {html: "#{e} \n", success: false} )
		end

		Net::SSH.start(server.public_ip, 'deploy', :timeout => 10, :number_of_password_prompts => 0) do | ssh |

			ssh.exec!("mkdir ~/.autodeploy")

		ssh.exec!("cat <<'EOF' > ~/.autodeploy/rbenv.sh 
#{@rbenv_script}
EOF")
				action_notify( {html: "Uploaded ~/.autodeploy/rbenv.sh \n" } )

				ssh.exec!("sed -i -e 's/\r$//' ~/.autodeploy/rbenv.sh")

				# Execute setup script
				ssh.exec!('bash ~/.autodeploy/rbenv.sh "2.4.1" | tee -a ~/.autodeploy/rbenv.log') do |channel, stream, data|
					action_notify( {html: "#{data} \n"} )
				end

				action_notify( {html: "<b style='color: green'>Server installation complete with following packages..!</b> \n"} )

				ssh.exec!("nginx -v; ruby -v; psql --version; passenger -v; redis-server -v; node --version; yarn -v") do |channel, stream, data|
					action_notify( {html: "#{data} \n"} )
				end

				ssh.exec!("ssh-keygen -f id_rsa -t rsa -N '' -f ~/.ssh/id_rsa")
				
				ssh.exec!("cat ~/.ssh/id_rsa.pub") do |channel, stream, data|
					action_notify( {html: "#{data} \n"} )
				end

				action_notify( {html: "#{data} \n"} )
			end

	end

	private 

	def test_connection

	end

	def action_notify(data)
		ActionCable.server.broadcast "server:#{@server.id}", data
	end
end
