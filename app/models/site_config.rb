# frozen_string_literal: true



class SiteConfig < ApplicationRecord
  TILE_SERVER_TYPES = %w[layers wms].freeze

  KEY = "SiteConfig"
  validates :default_locale, inclusion: { in: UserProfile.all_locales.values.map(&:locale) }
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name } }
  after_save :wipe_cache

  dragonfly_accessor :logo
  dragonfly_accessor :small_logo

  FUNDER_IMAGES = 1.upto(6).map { |n| :"funder_image_footer#{n}" }.freeze
  FUNDER_IMAGES.each do |funder_image|
    dragonfly_accessor funder_image
  end

  def to_struct
    OpenStruct.new(
      attributes.merge(
        dragonfly_attachments.each_with_object({}) do |(k, v), hsh|
          hsh[k] = v.stored? ? v.url : nil
        end
      )
    )
  end

  (%i[logo small_logo] + FUNDER_IMAGES).each do |meth|
    define_method "#{meth}_url" do
      public_send(meth)&.url || ""
    end
  end

  private

  def wipe_cache
    Rails.cache.delete(KEY)
    true
  end
end

# == Schema Information
#
# Table name: site_configs
#
#  id                         :integer          not null, primary key
#  admin_email                :string           default("cyclescape-comments@cyclestreets.net"), not null
#  application_name           :string           not null
#  blog_about_url             :string           default("http://blog.cyclescape.org/about/"), not null
#  blog_url                   :string           default("http://blog.cyclescape.org/"), not null
#  blog_user_guide_url        :string           default("http://blog.cyclescape.org/guide/"), not null
#  default_email              :string           not null
#  default_locale             :string           not null
#  email_domain               :string           not null
#  facebook_link              :string
#  funder_image_footer1_uid   :string
#  funder_image_footer2_uid   :string
#  funder_image_footer3_uid   :string
#  funder_image_footer4_uid   :string
#  funder_image_footer5_uid   :string
#  funder_image_footer6_uid   :string
#  funder_name_footer1        :string
#  funder_name_footer2        :string
#  funder_name_footer3        :string
#  funder_name_footer4        :string
#  funder_name_footer5        :string
#  funder_name_footer6        :string
#  funder_url_footer1         :string
#  funder_url_footer2         :string
#  funder_url_footer3         :string
#  funder_url_footer4         :string
#  funder_url_footer5         :string
#  funder_url_footer6         :string
#  ga_base_domain             :string
#  geocoder_key               :string
#  geocoder_url               :string           not null
#  google_street_view_api_key :string
#  logo_uid                   :string
#  nowhere_location           :geometry({:srid= not null, geometry, 4326
#  small_logo_uid             :string
#  tile_server1_name          :string           default("OpenCycleMap"), not null
#  tile_server1_options       :string           default("{}"), not null
#  tile_server1_type          :string           default("layers"), not null
#  tile_server1_url           :string           default("https://{s}.tile.cyclestreets.net/opencyclemap/{z}/{x}/{y}@2x.png"), not null
#  tile_server2_name          :string           default("OS StreetView")
#  tile_server2_options       :string           default("{}"), not null
#  tile_server2_type          :string           default("layers"), not null
#  tile_server2_url           :string           default("https://{s}.tile.cyclestreets.net/osopendata/{z}/{x}/{y}.png")
#  tile_server3_name          :string           default("OpenStreetMap")
#  tile_server3_options       :string           default("{}"), not null
#  tile_server3_type          :string           default("layers"), not null
#  tile_server3_url           :string           default("https://{s}.tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png")
#  timezone                   :string           not null
#  twitter_link               :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  ga_account_id              :string
#
