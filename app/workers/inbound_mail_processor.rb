class InboundMailProcessor
  def self.queue
    :inbound_mail
  end

  def self.perform(mail_id)
    mail = InboundMail.find(mail_id)
    if mail.message.to.first.match(/^thread-([^@]+)/)
      deliver_thread_reply(mail, $1)
    end
  end

  def self.deliver_thread_reply(mail, thread_token)
    thread = MessageThread.find_by_public_token(thread_token)
    fail "Thread #{thread_token.inspect} not found" if thread.nil?

    # This raises an exception if it fails
    messages = thread.add_messages_from_email!(mail)
    thread.add_subscriber(messages.first.created_by) unless messages.first.created_by.ever_subscribed_to_thread?(thread)
    messages.each do |message|
      ThreadNotifier.notify_subscribers(thread, ["new", message.component_name].join("_").to_sym, message)
    end
  end
end
