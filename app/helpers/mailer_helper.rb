module MailerHelper
  # Our domain name
  def domain
    Rails.application.config.default_email_from_domain
  end

  # Message-specific email address
  # No name in the address to stop it being added to automatic client address books
  def message_address(message)
    "<message-#{message.public_token}@#{domain}>"
  end

  def message_chain(message)
    return "" unless message
    "#{message_chain(message.in_reply_to)} #{message_address(message)}".strip
  end

  # Notifications are sent from a fixed email but with different names
  def user_notification_address(user)
    ['"', user.name, '" <notifications@', domain, '>'].join
  end
end
