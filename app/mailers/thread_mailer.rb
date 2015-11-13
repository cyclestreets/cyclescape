class ThreadMailer < ActionMailer::Base
  include MailerHelper
  helper :mailer
  default from: Rails.application.config.default_email_from

  def digest(user, threads_messages)
    @threads_messages = threads_messages
    @subscriber = user

    mail(to: @subscriber.name_with_email,
         subject: t('mailers.thread_mailer.digest.subject', date: Date.today),
         reply_to: no_reply_address,
        )
  end

  def common(message, subscriber)
    @message = message
    @thread = message.thread
    @subscriber = subscriber

    mail(to: subscriber.name_with_email,
         subject: t('mailers.thread_mailer.common.subject', title: @thread.title, count: @thread.message_count),
         from: user_notification_address(message.created_by),
         references: message_chain(@message.in_reply_to, @thread),
         message_id: message_address(@message),
         reply_to: message_address(@message),
         in_reply_to: thread_address(@thread))
  end
end
