class SiteConfig < ActiveRecord::Base
  KEY = "SiteConfig".freeze
  validates :default_locale, inclusion: { in: UserProfile.all_locales.values.map(&:locale) }
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name } }
  before_save :wipe_cache

  dragonfly_accessor :logo

  1.upto(6).each do |n|
    dragonfly_accessor :"funder_image_footer#{n}"
  end

  private

  def wipe_cache
    Rails.cache.delete(KEY)
    true
  end
end
