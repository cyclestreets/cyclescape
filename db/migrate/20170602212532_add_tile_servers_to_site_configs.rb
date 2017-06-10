class AddTileServersToSiteConfigs < ActiveRecord::Migration
  def change
    add_column :site_configs, :tile_server1_name, :string, null: false, default: "OpenCycleMap"
    add_column :site_configs, :tile_server1_url, :string, null: false, default: "https://{s}.tile.cyclestreets.net/opencyclemap/{z}/{x}/{y}@2x.png"
    add_column :site_configs, :tile_server2_name, :string, default: "OS StreetView"
    add_column :site_configs, :tile_server2_url, :string, default: "https://{s}.tile.cyclestreets.net/osopendata/{z}/{x}/{y}.png"
    add_column :site_configs, :tile_server3_name, :string, default: "OpenStreetMap"
    add_column :site_configs, :tile_server3_url, :string, default: "https://{s}.tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png"
  end
end
