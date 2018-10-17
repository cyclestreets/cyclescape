class AddGoogleStreetViewApiKeyToSiteConfigs < ActiveRecord::Migration
  def change
    add_column :site_configs, :google_street_view_api_key, :string
  end
end
