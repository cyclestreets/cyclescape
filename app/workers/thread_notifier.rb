class ThreadNotifier
  def self.queue
    :outbound_mail
  end

  # Call +method+ with *args on ourself
  def self.perform(method, *args)
    send(method, *args)
  end

  # Main entry point, begin notification of subscbribers to +thread+ with message +type+ and
  # optional +message+ object
  def self.notify_subscribers(thread, type, message = nil)
    Resque.enqueue(ThreadNotifier, :queue_messages_for_subscribers, thread.id, type, message ? message.id : nil)
  end

  # Queue the notification for each subscriber
  def self.queue_messages_for_subscribers(thread_id, type, message_id)
    thread = MessageThread.find(thread_id)
    thread.subscribers.each do |subscriber|
      Resque.enqueue(ThreadNotifier, :send_notification, type, message_id, subscriber.id)
    end
  end

  # Generate and send out the notification email
  def self.send_notification(type, message_id, subscriber_id)
    message = Message.find(message_id)
    subscriber = message.thread.subscribers.find(subscriber_id)
    ThreadMailer.send(type, message, subscriber).deliver
  end
end
