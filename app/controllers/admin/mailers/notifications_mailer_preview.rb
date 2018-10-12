class NotificationsMailerPreview < ActionMailer::Preview
  def group_membership_request_confirmed
    Notifications.group_membership_request_confirmed(GroupMembershipRequest.last)
  end

  def new_group_request
    Notifications.new_group_request(GroupRequest.last, User.admin.ids)
  end

  def new_group_thread
    Notifications.new_group_thread(thread, user)
  end

  def new_user_location_issue
    Notifications.new_user_location_issue(user.location, issue)
  end

  def new_user_location_issue_thread
    Notifications.new_user_location_issue_thread(thread, user.location)
  end

  def new_group_location_issue
    Notifications.new_group_location_issue(user, group, issue)
  end

  def upcoming_issue_deadline
    issue = Issue.joins(:threads).where.not(deadline: nil).last
    Notifications.upcoming_issue_deadline(user, issue, issue.threads.first)
  end

  def upcoming_thread_deadline
    deadline_message = DeadlineMessage.last
    Notifications.upcoming_thread_deadline(user, deadline_message.thread, deadline_message)
  end

  private

  def thread
    MessageThread.joins(:group).last
  end

  def issue
    Issue.last
  end

  def user
    User.find(5)
  end

  def group
    Group.find(2)
  end
end
