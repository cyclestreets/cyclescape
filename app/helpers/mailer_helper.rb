module MailerHelper
  # Our domain name
  def domain
    Rails.application.config.default_email_from_domain
  end

  # Thread-specific email address
  # No name in the address to stop it being added to automatic client address books
  def thread_address(thread)
    "#<thread-#{thread.public_token}@#{domain}>"
  end

  # Notifications are sent from a fixed email but with different names
  def user_notification_address(user)
    ['"', user.name, '" <notifications@', domain, ">"].join
  end
end
