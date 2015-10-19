class InboundMailProcessor
  def self.queue
    :inbound_mail
  end

  def self.perform(mail_id)
    mail = InboundMail.find(mail_id)
    to_address = mail.message.to.first
    thread_match = to_address.match(/^thread-([^@]+)/)
    message_match = to_address.match(/^message-([^@]+)/)
    deliver_thread_reply(mail, thread_match.try(:[], 1), message_match.try(:[], 1))
  end

  def self.deliver_thread_reply(mail, thread_token, message_token)
    message = Message.find_by(public_token: message_token)
    thread = if message
               message.thread
             else
               MessageThread.find_by(public_token: thread_token)
             end
    fail "Message #{message_token.inspect} and thread #{thread_token.inspect} not found" unless thread || message

    # This raises an exception if it fails
    messages = thread.add_messages_from_email!(mail, message)
    thread.add_subscriber(messages.first.created_by) unless messages.first.created_by.ever_subscribed_to_thread?(thread)
    messages.each do |mess|
      ThreadNotifier.notify_subscribers(thread, ['new', mess.component_name].join('_').to_sym, mess)
    end
  end
end
