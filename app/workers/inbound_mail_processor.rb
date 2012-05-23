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
    raise "Thread #{thread_token.inspect} not found" if thread.nil?

    # This raises an exception if it fails
    message = thread.add_message_from_email!(mail)
    thread.add_subscriber(message.created_by) unless message.created_by.ever_subscribed_to_thread?(thread)
    ThreadNotifier.notify_subscribers(thread, :new_message, message)
  end
end
