class AddColumsToApp < ActiveRecord::Migration[5.1]
  def change
    add_column :apps, :pg_status, :integer, default: 0
    add_column :apps, :redis_status, :integer, default: 0
    add_column :apps, :clone_status, :integer, default: 0
    add_column :apps, :deploy_status, :integer, default: 0
    add_column :apps, :nginx_ssl, :boolean, default: false
  end
end
