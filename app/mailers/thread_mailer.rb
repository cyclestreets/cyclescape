class ThreadMailer < ActionMailer::Base
  default from: Rails.application.config.default_email_from

  def new_message(message, subscriber)
    common(message, subscriber)
  end

  def new_photo_message(message, subscriber)
    attachments['photo.jpg'] = message.component.photo_medium.data
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

  protected

  def common(message, subscriber)
    @message = message
    @thread = message.thread
    @subscriber = subscriber
    email_from = ['"', t("application_name"),
        '" <thread-', @thread.public_token, "@",
        Rails.application.config.default_email_from_domain, ">"]
    mail(to: subscriber.name_with_email,
         subject: "Re: #{@thread.title}",
         from: email_from.join)
  end
end
