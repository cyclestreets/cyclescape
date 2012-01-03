class InboundMailProcessor
  def self.queue
    :inbound_mail
  end

  def self.perform(mail_id)
    mail = InboundMail.find(mail_id)
    if mail.message.to.first.match(/^thread-([^@]+)/)
      from_address = mail.message.header[:from].addresses.first
      from_name = mail.message.header[:from].display_names.first

      thread = MessageThread.find_by_public_token($1)
      raise "Thread #{$1.inspect} not found" if thread.nil?

      user = User.find_or_invite(from_address, from_name)
      raise "Invalid user" if user.nil?

      message = thread.messages.build(
          body: mail.message.body.to_s,
          created_by: user)
      message.save!

      ThreadNotifier.notify_subscribers(thread, :new_message, message)
    end
  end
end
