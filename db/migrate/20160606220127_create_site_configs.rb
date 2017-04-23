class CreateSiteConfigs < ActiveRecord::Migration
  def change
    create_table :site_configs do |t|
      t.string :logo_uid
      t.string :application_name, null: false
      t.string :funder_image_footer1_uid
      t.string :funder_image_footer2_uid
      t.string :funder_image_footer3_uid
      t.string :funder_image_footer4_uid
      t.string :funder_image_footer5_uid
      t.string :funder_image_footer6_uid
      t.string :funder_name_footer1
      t.string :funder_name_footer2
      t.string :funder_name_footer3
      t.string :funder_name_footer4
      t.string :funder_name_footer5
      t.string :funder_name_footer6
      t.string :funder_url_footer1
      t.string :funder_url_footer2
      t.string :funder_url_footer3
      t.string :funder_url_footer4
      t.string :funder_url_footer5
      t.string :funder_url_footer6
      t.geometry :nowhere_location, srid: 4326, null: false
      t.string :facebook_link
      t.string :twitter_link
      t.text :footer_links_html, null: false
      t.text :header_html, null: false
      t.string :default_locale, null: false
      t.string :timezone, null: false
      t.string :ga_account_id
      t.string :ga_base_domain
      t.string :default_email, null: false
      t.string :email_domain, null: false
      t.string :geocoder_url, null: false
      t.string :geocoder_key

      t.timestamps null: false
    end

    execute "INSERT INTO site_configs (application_name, nowhere_location,
                                       facebook_link, twitter_link,
                                       footer_links_html, header_html, default_locale,
                                       timezone, geocoder_url,
                                       ga_account_id, ga_base_domain,
                                       default_email, email_domain,
                                       updated_at, created_at)
     VALUES ('Cyclescape', ST_GeomFromText('POINT(0.1275 51.5032)', 4326),
     'https://www.facebook.com/CycleStreets', 'https://twitter.com/cyclescape',
     '<li><small><a href=\"http://blog.cyclescape.org/\">Cyclescape blog</a></small>
</li>
<li>
<small><a href=\"http://blog.cyclescape.org/guide/\">User guide</a></small>
</li>
<li>
<small><a href=\"/pages/privacypolicy\">Privacy Policy</a></small>
</li>
<li>',
     '<li><a href=\"http://blog.cyclescape.org/about/\">About</a></li><li><a href=\"http://blog.cyclescape.org/guide/\">User guide</a></li>',
     'en-GB', 'Europe/London', 'https://api.cyclestreets.net/v2/geocoder',
     'UA-28721275-1', 'cyclescape.org', 'Cyclescape <info@cyclescape.org>', 'cyclescape.org', now(), now());"
  end
end
