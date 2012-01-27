class Notifications < ActionMailer::Base
  default from: Cyclescape::Application.config.default_email_from

  def group_membership_request_confirmed(request)
    @member = request.user
    @group = request.group
    mail(to: @member.name_with_email,
         subject: t('.mailers.notifications.gmr_confirmed.subject', group_name: @group.name))
  end

  # Send notification to member that thread has been created
  def new_group_thread(thread, member)
    @thread = thread
    @group = thread.group
    @member = member
    raise "Thread does not belong to group" if @group.nil?
    mail to: @member.name_with_email,
         subject: t("mailers.notifications.new_group_thread.subject",
           group_name: @group.name, thread_title: @thread.title)
  end
end
