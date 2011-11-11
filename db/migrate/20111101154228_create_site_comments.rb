class CreateSiteComments < ActiveRecord::Migration
  def change
    create_table :site_comments do |t|
      t.integer :user_id
      t.string :name
      t.string :email
      t.text :body, null: false
      t.string :context_url
      t.text :context_data
      t.datetime :created_at, null: false
      t.datetime :viewed_at
    end
  end
end
