# frozen_string_literal: true

class Notifications < ActionMailer::Base
  # `include` to use it in the methods in this mailer and `helper` to use it in the views
  include MailerHelper
  helper MailerHelper
  layout "basic_email"
  default from: ->(_) { SiteConfig.first.default_email }

  def group_membership_request_confirmed(request)
    @member = request.user
    @group = request.group
    mail(to: @member.name_with_email,
         subject: t("mailers.notifications.gmr_confirmed.subject", group_name: @group.name, application_name: site_config.application_name))
  end

  def group_membership_request_rejected(request)
    @group = request.group
    @request = request
    mail(to: request.user.name_with_email,
         subject: t("mailers.notifications.gmr_rejected.subject", group_name: @group.name, application_name: site_config.application_name))
  end

  def new_group_request(request, admins_ids)
    @request = request
    mail(to: User.where(id: admins_ids).map(&:email),
         subject: t("mailers.notifications.new_group_request.subject",
                    group_name: @request.name, user_name: @request.user.full_name, application_name: site_config.application_name))
  end

  def group_request_confirmed(group, request)
    @user = request.user
    @group = group
    mail(to: @user.email,
         subject: t("mailers.notifications.group_request_confirmed.subject", group_name: @group.name, application_name: site_config.application_name))
  end

  def group_request_rejected(request)
    @request = request
    user = request.user
    mail(to: user.email,
         subject: t("mailers.notifications.group_request_rejected.subject", group_request_name: @request.name, application_name: site_config.application_name))
  end

  def new_group_membership_request(request)
    @user = request.user
    @group = request.group
    @request = request
    if @group.prefs.notify_membership_requests?
      email_address = if @group.prefs.membership_secretary
                        @group.prefs.membership_secretary.name_with_email
                      elsif @group.email.present?
                        @group.name_with_email
                      end
      if email_address
        mail to: email_address,
             subject: t("mailers.notifications.new_gmr.subject", user_name: @user.name, group_name: @group.name, application_name: site_config.application_name)
      end
    end
  end

  # Send a notification to a user that they have been added to a group
  def added_to_group(membership)
    @member = membership.user
    @group = membership.group
    body = Mustache.render(@group.profile.new_user_email, full_name: @member.full_name) if @group.profile.new_user_email
    mail(
      to: @member.name_with_email,
      subject: t("mailers.notifications.added_to_group.subject", group_name: @group.name, application_name: site_config.application_name),
      body: body
    )
  end

  # Send notification to member that thread has been created
  def new_group_thread(thread, member)
    @thread = thread
    @group = thread.group
    message = thread.first_message
    @message_author = message.created_by
    @member = member
    raise "Thread does not belong to group" if @group.nil?

    mail to: @member.name_with_email,
         from: user_notification_address(@message_author),
         reply_to: message_address(message),
         subject: t("mailers.notifications.new_group_thread.subject",
                    group_name: @group.name, thread_title: @thread.title, application_name: site_config.application_name)
  end

  def new_user_location_issue(user_location, issue)
    @issue = issue
    @user_location = user_location
    mail to: @user_location.user.name_with_email,
         subject: t("mailers.notifications.new_user_location_issue.subject",
                    issue_title: @issue.title, application_name: site_config.application_name)
  end

  # Send a notification to a user that a thread has started on an issue in their area
  def new_user_location_issue_thread(thread, user_location)
    @thread = thread
    @user_location = user_location
    @user = user_location.user
    @message = thread.first_message
    raise "Thread does not have an issue" unless @thread.issue

    mail to: @user.name_with_email,
         from: user_notification_address(@message.created_by),
         reply_to: message_address(@message),
         subject: t("mailers.notifications.new_user_location_issue_thread.subject",
                    issue_title: @thread.issue.title, application_name: site_config.application_name)
  end

  def new_group_location_issue(user, group, issue)
    @user = user
    @group = group
    @issue = issue
    mail to: @user.name_with_email,
         subject: t("mailers.notifications.new_group_location_issue.subject",
                    group_name: @group.name, issue_title: @issue.title, application_name: site_config.application_name)
  end

  def new_user_confirmed(user)
    @user = user
    mail to: @user.name_with_email,
         subject: t("mailers.notifications.new_user_confirmed.subject", application_name: site_config.application_name)
  end

  def upcoming_issue_deadline(user, issue, thread)
    @user = user
    @issue = issue
    @thread = thread
    mail to: @user.name_with_email,
         subject: t("mailers.notifications.upcoming_issue_deadline.subject", issue_title: @issue.title, application_name: site_config.application_name)
  end

  def upcoming_thread_deadline(user, thread, deadline_message)
    @user = user
    @thread = thread
    @deadline_message = deadline_message
    mail to: @user.name_with_email,
         reply_to: message_address(deadline_message.message),
         subject: t("mailers.notifications.upcoming_thread_deadline.subject", thread_title: @thread.title, application_name: site_config.application_name)
  end

  private

  def site_config
    @site_config ||= SiteConfig.first
  end
end
