class ThreadMailer < ActionMailer::Base
  include MailerHelper
  default from: Rails.application.config.default_email_from

  def new_message(message, subscriber)
    common(message, subscriber)
  end

  def new_photo_message(message, subscriber)
    # attachments['photo.jpg'] = message.component.photo_medium.data
    common(message, subscriber)
  end

  def new_deadline_message(message, subscriber)
    common(message, subscriber)
  end

  def new_link_message(message, subscriber)
    common(message, subscriber)
  end

  def new_library_item_message(message, subscriber)
    common(message, subscriber)
  end

  def new_document_message(message, subscriber)
    common(message, subscriber)
  end

  protected

  def common(message, subscriber)
    @message = message
    @thread = message.thread
    @subscriber = subscriber
    email_from = user_notification_address(message.created_by)
    reply_to = thread_address(@thread)
    mail(to: subscriber.name_with_email,
         subject: t("mailers.thread_mailer.common.subject", title: @thread.title, count: @thread.message_count),
         from: email_from,
         reply_to: reply_to)
  end
end
