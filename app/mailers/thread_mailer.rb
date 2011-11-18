class ThreadMailer < ActionMailer::Base
  default from: "no-reply@cyclescape.org"

  def new_message(message, subscriber)
    @message = message
    @thread = message.thread
    @subscriber = subscriber
    mail(to: subscriber.name_with_email,
         subject: "Re: #{@thread.title}",
         from: "\"#{t("application_name")}\" <thread-#{@thread.public_token}@cyclescape.org>")
  end
end
