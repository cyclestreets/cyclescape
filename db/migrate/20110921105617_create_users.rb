class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :full_name, null: false
      t.string :display_name
      t.string :role, null: false
      t.database_authenticatable
      t.confirmable
      t.recoverable
      t.rememberable
      t.datetime :disabled_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
