class AddSiteConfig < ActiveRecord::Migration
  def change
    add_column :site_configs, :tile_server1_type, :string, null: false, default: "layers"
    add_column :site_configs, :tile_server2_type, :string, null: false, default: "layers"
    add_column :site_configs, :tile_server3_type, :string, null: false, default: "layers"
    add_column :site_configs, :tile_server1_options, :string, null: false, default: "{}"
    add_column :site_configs, :tile_server2_options, :string, null: false, default: "{}"
    add_column :site_configs, :tile_server3_options, :string, null: false, default: "{}"
  end
end
