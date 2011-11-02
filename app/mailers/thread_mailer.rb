class ThreadMailer < ActionMailer::Base
  default from: "no-reply@cyclescape.net"

  def new_message(message, subscriber)
    @message = message
    @subscriber = subscriber
    mail(to: subscriber.name_with_email,
         subject: "Re: #{message.thread.title}")
  end
end
