class AddBlogAndAdminEmailToSiteConfigs < ActiveRecord::Migration
  def change
    add_column :site_configs, :admin_email, :string, default: "cyclescape-comments@cyclestreets.net", null: false
    add_column :site_configs, :blog_url, :string, default: "http://blog.cyclescape.org/", null: false
    add_column :site_configs, :blog_user_guide_url, :string, default: "http://blog.cyclescape.org/guide/", null: false
  end
end
