class SiteConfig < ActiveRecord::Base
  KEY = "SiteConfig".freeze
  validates :default_locale, inclusion: { in: UserProfile.all_locales.values.map(&:locale) }
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name } }
  before_save :wipe_cache

  dragonfly_accessor :logo
  dragonfly_accessor :small_logo

  1.upto(6).each do |n|
    dragonfly_accessor :"funder_image_footer#{n}"
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

  private

  def wipe_cache
    Rails.cache.delete(KEY)
    true
  end
end
