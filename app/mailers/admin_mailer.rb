# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def new_site_comment(comment)
    mail(
      to: site_config.admin_email,
      reply_to: comment.email,
      subject: t("mailers.admin_mailer.new_site_comment.subject", id: comment.id),
      body: t("mailers.admin_mailer.new_site_comment.body",
              name: comment.name,
              email: comment.email,
              url: comment.context_url,
              body: comment.body)
    )
  end
end
