class AddPlanitApiKeyToSiteConfigs < ActiveRecord::Migration[5.2]
  def change
    add_column :site_configs, :planit_api_key, :string
  end
end
