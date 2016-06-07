class ThreadMailer < ActionMailer::Base
  include MailerHelper
  helper :mailer
  default from: Rails.application.config.default_email_from

  def digest(user, threads_messages)
    @threads_messages = threads_messages
    @subscriber = user

    mail(to: @subscriber.name_with_email,
         subject: t('mailers.thread_mailer.digest.subject', date: Date.current.to_s(:long)),
         reply_to: no_reply_address,
        )
  end

  def common(message, subscriber)
    @message = message
    @thread = message.thread
    @subscriber = subscriber
    @subscription = @thread.subscriptions.find_by(user: @subscriber)
    subject = if @thread.private_to_committee?
                "mailers.thread_mailer.common.committee_subject"
              else
                "mailers.thread_mailer.common.subject"
              end
    if @message.notification_name == :new_deadline_message
      cal = Icalendar::Calendar.new
      cal.add_event(@message.component.to_ical)
      attachments['deadline.ics'] = {mime_type: 'text/calendar',
                                     content: cal.to_ical }
    end
    mail(to: subscriber.name_with_email,
         subject: t(subject, title: @thread.title, count: @thread.messages.count),
         from: user_notification_address(message.created_by),
         references: message_chain(@message.in_reply_to, @thread),
         message_id: message_address(@message),
         reply_to: message_address(@message),
         in_reply_to: thread_address(@thread))
  end
end
