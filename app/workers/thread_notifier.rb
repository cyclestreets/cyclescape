class ThreadNotifier
  class << self
    def queue
      :outbound_mail
    end

    # Call +method+ with *args on ourself
    def perform(method, *args)
      send(method, *args)
    end

    # Notification of subscribers to +thread+ with +message+ object
    def notify_subscribers(thread, message)
      to_subscribers(thread) do |subscriber|
        ThreadMailer.send(:common, message, subscriber).deliver_later
      end
    end

    def notify_subscribers_event(thread, event, event_user)
      to_subscribers(thread) do |subscriber|
        ThreadEventMailer.send(:common, thread, event.to_s, event_user, subscriber).deliver_later
      end
    end

    private

    def to_subscribers(thread)
      thread.email_subscribers.each do |subscriber|
        yield subscriber
      end
    end
  end
end
