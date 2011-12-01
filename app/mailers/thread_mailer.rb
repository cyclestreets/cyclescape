class ThreadMailer < ActionMailer::Base
  default from: Rails.application.config.default_email_from

  def new_message(message, subscriber)
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
