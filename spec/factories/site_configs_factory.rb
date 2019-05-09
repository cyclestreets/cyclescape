# frozen_string_literal: true

FactoryBot.define do
  factory :site_config do
    logo { Pathname.new(File.join(%w[spec support images abstract-100-100.jpg])) }
    application_name "Cyclescape"
    funder_image_footer1 { Pathname.new(File.join(%w[spec support images abstract-100-100.jpg])) }
    funder_name_footer1 "Great Funder"
    funder_url_footer1 "http://funder.example.com"
    nowhere_location "POINT(0.1275 51.5032)"
    facebook_link "https//www.facebook.com/CycleStreets"
    twitter_link "https://twitter.com/cyclescape"
    default_locale "en-GB"
    timezone "Europe/London"
    geocoder_url "https://api.cyclestreets.net/v2/geocoder"
    email_domain "cyclescape.org"
    default_email "info@example.com"
    blog_url "http://blog.cyclescape.org/"
    blog_user_guide_url "http://blog.cyclescape.org/guide/"
    admin_email "cyclescape-comment@cy.net"
  end
end
