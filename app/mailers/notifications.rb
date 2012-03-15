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

  def new_user_location_issue(user, issue, category)
    @user = user
    @issue = issue
    @category = category
    mail to: @user.name_with_email,
         subject: t("mailers.notifications.new_user_location_issue.subject",
                    category: category.name.downcase)
  end

  # Send a notification to a user that a thread has started on an issue in their area
  def new_user_location_issue_thread(thread, user_location)
    @thread = thread
    @user_location = user_location
    @user = user_location.user
    @message = thread.messages.first
    raise "Thread does not have an issue" unless @thread.issue
    mail to: @user.name_with_email,
         subject: t('.mailers.notifications.new_user_location_issue_thread.subject',
                   issue_title: @thread.issue.title)
  end
end
