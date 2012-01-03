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
    from_address = mail.message.header[:from].addresses.first
    from_name = mail.message.header[:from].display_names.first

    thread = MessageThread.find_by_public_token(thread_token)
    raise "Thread #{thread_token.inspect} not found" if thread.nil?

    user = User.find_or_invite(from_address, from_name)
    raise "Invalid user" if user.nil?

    # For multipart messages we pull out the text/plain content
    body = if mail.message.multipart?
      mail.message.text_part.body
    else
      mail.message.body
    end

    message = thread.messages.build
    message.body = body.to_s
    message.created_by = user
    message.save!

    ThreadNotifier.notify_subscribers(thread, :new_message, message)
  end
end
