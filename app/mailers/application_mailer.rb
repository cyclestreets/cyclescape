class ApplicationMailer < ActionMailer::Base
  # `include` to use it in the methods in this mailer and `helper` to use it in the views
  include MailerHelper
  helper MailerHelper
  layout "basic_email"
  default from: ->(_) { SiteConfig.first.default_email }

  private

  def site_config
    @site_config ||= Rails.cache.fetch(SiteConfig::KEY, expires_in: 1.week) do
      SiteConfig.first.to_struct
    end
  end

  def set_time_zone(user)
    Time.use_zone(user.try(:time_zone) || @site_config.try(:time_zone) || "London") { yield }
  end
end
