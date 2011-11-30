class Notifications < ActionMailer::Base
  default from: Cyclescape::Application.config.default_email_from

  def thread_subscribed(subscription)
    @subscriber = subscription.user
    @thread = subscription.thread
    mail(to: @subscriber.name_with_email,
         subject: "Subscribed to \"#{@thread.title}\"")
  end

  def group_membership_request_confirmed(request)
    @member = request.user
    @group = request.group
    mail(to: @member.name_with_email,
         subject: t('.mailers.notifications.gmr_confirmed.subject', group_name: @group.name))
  end
end
