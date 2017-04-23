FactoryGirl.define do
  factory :site_config do
    logo { Pathname.new(File.join(%w(spec support images abstract-100-100.jpg))) }
    application_name "Cyclescape"
    funder_image_footer1 { Pathname.new(File.join(%w(spec support images abstract-100-100.jpg))) }
    funder_name_footer1 "Great Funder"
    funder_url_footer1 "http://funder.example.com"
    nowhere_location "POINT(0.1275 51.5032)"
    facebook_link "https//www.facebook.com/CycleStreets"
    twitter_link 'https://twitter.com/cyclescape'
    footer_links_html '<li><small><a href=\"http://blog.cyclescape.org/\">Cyclescape blog</a></small>
</li>
<li>
<small><a href=\"http://blog.cyclescape.org/guide/\">User guide</a></small>
</li>
<li>
<small><a href=\"/pages/privacypolicy\">Privacy Policy</a></small>
</li>
<li>'
    header_html '<li><a href=\"http://blog.cyclescape.org/about/\">About</a></li><li><a href=\"http://blog.cyclescape.org/guide/\">User guide</a></li>'
    default_locale "en-GB"
    timezone "Europe/London"
    geocoder_url 'https://api.cyclestreets.net/v2/geocoder'
    email_domain "cyclescape.org"
    default_email "info@example.com"
  end
end
