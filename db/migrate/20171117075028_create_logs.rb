class CreateLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :logs do |t|
      t.references :server, foreign_key: true
      t.integer :status
      t.string :name
      t.datetime :started
      t.datetime :completed
      t.text :body

      t.timestamps
    end
  end
end
