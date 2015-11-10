class Notifications < ActionMailer::Base
  include MailerHelper
  default from: Cyclescape::Application.config.default_email_from

  def group_membership_request_confirmed(request)
    @member = request.user
    @group = request.group
    mail(to: @member.name_with_email,
         subject: t('mailers.notifications.gmr_confirmed.subject', group_name: @group.name))
  end

  def new_group_request(request, admins_ids)
    @request = request
    mail(to: User.where(id: admins_ids).map(&:email),
         subject: t('mailers.notifications.new_group_request.subject',
                    group_name: @request.name, user_name: @request.user.full_name))
  end

  def group_request_confirmed(group, request)
    @user = request.user
    @group = group
    mail(to: @user.email,
         subject: t('mailers.notifications.group_request_confirmed.subject', group_name: @group.name))
  end

  def group_request_rejected(request)
    @request = request
    user = request.user
    mail(to: user.email,
         subject: t('mailers.notifications.group_request_rejected.subject', group_request_name: @request.name))
  end

  def new_group_membership_request(request)
    @user = request.user
    @group = request.group
    @request = request
    if @group.prefs.notify_membership_requests?
      if @group.prefs.membership_secretary
        mail to: @group.prefs.membership_secretary.name_with_email,
             subject: t('mailers.notifications.new_gmr.subject', user_name: @user.name, group_name: @group.name)
      elsif !@group.email.blank?
        mail to: @group.name_with_email,
             subject: t('mailers.notifications.new_gmr.subject', user_name: @user.name, group_name: @group.name)
      end
    end
  end

  # Send a notification to a user that they have been added to a group
  def added_to_group(membership)
    @member = membership.user
    @group = membership.group
    mail(to: @member.name_with_email,
         subject: t('mailers.notifications.added_to_group.subject', group_name: @group.name))
  end

  # Send notification to member that thread has been created
  def new_group_thread(thread, member)
    @thread = thread
    @group = thread.group
    message = thread.first_message
    @message_author = message.created_by
    @member = member
    fail 'Thread does not belong to group' if @group.nil?
    mail to: @member.name_with_email,
         from: user_notification_address(@message_author),
         reply_to: message_address(message),
         subject: t('mailers.notifications.new_group_thread.subject',
                    group_name: @group.name, thread_title: @thread.title)
  end

  def new_user_location_issue(user, issue, category)
    @user = user
    @issue = issue
    @category = category
    mail to: @user.name_with_email,
         subject: t('mailers.notifications.new_user_location_issue.subject',
                    issue_title: @issue.title)
  end

  # Send a notification to a user that a thread has started on an issue in their area
  def new_user_location_issue_thread(thread, user_location)
    @thread = thread
    @user_location = user_location
    @user = user_location.user
    @message = thread.messages.first
    fail 'Thread does not have an issue' unless @thread.issue
    mail to: @user.name_with_email,
         from: user_notification_address(@message.created_by),
         reply_to: message_address(@message),
         subject: t('mailers.notifications.new_user_location_issue_thread.subject',
                    issue_title: @thread.issue.title)
  end

  def new_group_location_issue(user, group, issue)
    @user = user
    @group = group
    @issue = issue
    mail to: @user.name_with_email,
         subject: t('mailers.notifications.new_group_location_issue.subject',
                    group_name: @group.name, issue_title: @issue.title)
  end

  def new_user_confirmed(user)
    @user = user
    mail to: @user.name_with_email,
         subject: t('mailers.notifications.new_user_confirmed.subject')
  end

end
