class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.string :short_name, null: false
      t.string :website
      t.string :email
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :disabled_at
    end
  end
end
