# frozen_string_literal: true

class InboundMailProcessor
  def self.queue
    :inbound_mail
  end

  def self.perform(mail_id)
    mail = InboundMail.find(mail_id)
    to_address = mail.message.to.first
    thread_token = to_address.match(/^thread-([^@]+)/).to_a[1]
    message_token = to_address.match(/^message-([^@]+)/).to_a[1]
    return unless thread_token || message_token
    deliver_thread_reply(mail, thread_token, message_token)
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
    thread.add_messages_from_email!(mail, message)
  end
end
