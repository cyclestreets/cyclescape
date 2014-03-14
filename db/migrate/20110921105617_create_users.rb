class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :full_name, null: false
      t.string :display_name
      t.string :role, null: false
      t.string :encrypted_password, null: false, default: ''
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.datetime :disabled_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
