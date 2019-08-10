# frozen_string_literal: true

class SiteConfig < ApplicationRecord
  TILE_SERVER_TYPES = %w[layers wms].freeze

  KEY = "SiteConfig"
  validates :default_locale, inclusion: { in: UserProfile.all_locales.values.map(&:locale) }
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name } }
  before_save :wipe_cache

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
