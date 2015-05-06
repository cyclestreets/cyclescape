class CreatePlanningApplications < ActiveRecord::Migration
  def change
    create_table :planning_applications do |t|
      t.integer :openlylocal_id, null: false
      t.string :openlylocal_url
      t.string :address
      t.string :postcode
      t.text :description
      t.string :council_name
      t.string :openlylocal_council_url
      t.string :url
      t.string :uid, null: false
      t.geometry :location, srid: 4326, null: false
      t.references :issue

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
    add_index :planning_applications, :issue_id
  end
end
