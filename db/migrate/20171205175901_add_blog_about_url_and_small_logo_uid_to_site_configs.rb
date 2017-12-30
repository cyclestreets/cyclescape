class AddBlogAboutUrlAndSmallLogoUidToSiteConfigs < ActiveRecord::Migration
  def change
    add_column :site_configs, :blog_about_url, :string, default: "http://blog.cyclescape.org/about/", null: false
    add_column :site_configs, :small_logo_uid, :string
  end
end
