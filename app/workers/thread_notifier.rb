class ThreadNotifier
  def self.queue
    :outbound_mail
  end

  # Call +method+ with *args on ourself
  def self.perform(method, *args)
    send(method, *args)
  end

  # Notification of subscribers to +thread+ with message +type+ and
  # optional +message+ object
  def self.notify_subscribers(thread, type, message = nil)
    thread.email_subscribers.each do |subscriber|
      ThreadMailer.send(type, message, subscriber).deliver_later
    end
  end
end
