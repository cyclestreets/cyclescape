# frozen_string_literal: true

class ThreadMailer < ApplicationMailer
  def digest(user, threads_messages)
    @threads_messages = threads_messages
    @subscriber = user
    set_time_zone(user) do
      mail(
        to: @subscriber.name_with_email,
        subject: t("mailers.thread_mailer.digest.subject", date: Date.current.to_s(:long), application_name: site_config.application_name),
        reply_to: no_reply_address
      )
    end
  end

  def common(message, subscriber)
    @message = message
    @thread = message.thread
    @subscriber = subscriber
    @subscription = @thread.subscriptions.find_by(user: @subscriber)
    return unless @subscription

    subject = if @thread.private_to_committee?
                "mailers.thread_mailer.common.committee_subject"
              else
                "mailers.thread_mailer.common.subject"
              end
    group_name = "[#{@thread.group.name}]" if @thread.group && @subscriber.memberships.count > 1

    set_time_zone(subscriber) do
      deadlines = @message.components.select { |component| component.notification_name == :new_deadline_message }
      deadlines.each.with_index do |deadline, idx|
        cal = Icalendar::Calendar.new
        cal.add_event(deadline.to_ical)
        attachments["deadline_#{idx}.ics"] = { mime_type: "text/calendar", content: cal.to_ical }
      end
      mail(
        to: subscriber.name_with_email,
        subject: t(
          subject,
          title: @thread.title, count: @thread.messages.count,
          application_name: site_config.application_name,
          group_name: group_name
        ),
        from: user_notification_address(message.created_by),
        references: message_chain(@message.in_reply_to, @thread),
        message_id: message_address(@message),
        reply_to: message_address(@message),
        in_reply_to: thread_address(@thread)
      )
    end
  end
end
