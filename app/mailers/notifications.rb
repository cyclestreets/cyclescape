class Notifications < ActionMailer::Base
  default from: "from@example.com"

  def thread_subscribed(subscription)
    @subscriber = subscription.user
    @thread = subscription.thread
    mail(to: @subscriber.name_with_email,
         subject: "Subscribed to \"#{@thread.title}\"")
  end
end
