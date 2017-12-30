class CreateServers < ActiveRecord::Migration[5.1]
  def change
    create_table :servers do |t|
    	t.references :user
      t.string :name
      t.string :public_ip
      t.boolean :is_active, default: false
      t.timestamps
    end
  end
end
