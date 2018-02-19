# frozen_string_literal: true

class AdminMailer < ActionMailer::Base
  default from: ->(_) { SiteConfig.first.default_email }

  def new_site_comment(comment)
    mail(
      to: SiteConfig.first.admin_email,
      subject: t("mailers.admin_mailer.new_site_comment.subject"),
      body: t("mailers.admin_mailer.new_site_comment.body",
              name: comment.name,
              email: comment.email,
              url: comment.context_url,
              body: comment.body)
    )
  end
end
