class ThreadEventMailer < ActionMailer::Base
  include MailerHelper
  helper :mailer
  default from: Rails.application.config.default_email_from

  def common(thread, event, event_user, subscriber)
    @thread = thread
    @event = event
    @event_user = event_user
    @subscriber = subscriber

    mail(to: subscriber.name_with_email,
         subject: t('mailers.thread_mailer.common.subject', title: @thread.title, count: @thread.messages.count),
         from: user_notification_address(event_user),
         in_reply_to: thread_address(@thread))
  end
end
