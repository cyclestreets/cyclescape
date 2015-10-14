class ThreadMailer < ActionMailer::Base
  include MailerHelper
  default from: Rails.application.config.default_email_from

  [:new_message, :new_photo_message, :new_deadline_message,
   :new_document_message, :new_link_message, :new_library_item_message,
   :new_street_view_message,
  ].each do |message_type|
    define_method message_type do |message, subscriber|
      common(message, subscriber)
    end
  end

  protected

  def common(message, subscriber)
    @message = message
    @thread = message.thread
    @subscriber = subscriber
    email_from = user_notification_address(message.created_by)

    mail(to: subscriber.name_with_email,
         subject: t('mailers.thread_mailer.common.subject', title: @thread.title, count: @thread.message_count),
         from: email_from,
         references: message_chain(@message.in_reply_to),
         reply_to: message_address(@message))
  end
end
