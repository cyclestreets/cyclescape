class CreateSiteConfigs < ActiveRecord::Migration
  def change
    create_table :site_configs do |t|
      t.string :logo_uuid
      t.string :title_tag
      t.string :domain
      t.string :footer1_uuid
      t.string :footer2_uuid
      t.string :footer3_uuid
      t.geometory :nowhere_location, srid: 4326
      t.string :tile_server1_name
      t.string :tile_server2_name
      t.string :tile_server3_name
      t.string :tile_server1_url
      t.string :tile_server2_url
      t.string :tile_server3_url
      t.text :footer_html
      t.text :header_html
      t.integer :default_locale
      t.integer :timezone
      t.string :ga_account_id
      t.string :ga_base_domain
      t.string :default_email
      t.string :devise_email
      t.string :geocoder_url

      t.timestamps null: false
    end
  end
end
