class Membership < ActiveRecord::Migration[5.1]
  def change
  	create_table :memberships do |t|
			t.references :user, foreign_key: true
			t.references :server, foreign_key: true
			t.integer :role, index: true, null: false, default: 0
			t.timestamps
		end
  end
end
