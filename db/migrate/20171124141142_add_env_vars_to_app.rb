class AddEnvVarsToApp < ActiveRecord::Migration[5.1]
  def change
    add_column :apps, :env_vars, :json
  end
end
