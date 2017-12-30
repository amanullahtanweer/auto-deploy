class CreateApps < ActiveRecord::Migration[5.1]
  def change
    create_table :apps do |t|
      t.references :server, foreign_key: true
      t.string :name
      t.string :repo_url
      t.string :branch
      t.string :domain

      t.timestamps
    end
  end
end
