class RemoveHtmlTextsFromSiteConfigs < ActiveRecord::Migration
  def change
    remove_column :site_configs, :footer_links_html, :text
    remove_column :site_configs, :header_html, :text
  end
end
