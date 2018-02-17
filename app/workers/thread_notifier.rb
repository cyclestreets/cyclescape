# frozen_string_literal: true

class ThreadNotifier
  class << self
    def queue
      :mailers
    end

    # Call +method+ with *args on ourself
    def perform(method, *args)
      send(method, *args)
    end

    # Notification of subscribers to +thread+ with +message+ object
    def notify_subscribers(thread, message)
      thread.email_subscribers.each do |subscriber|
        ThreadMailer.send(:common, message, subscriber).deliver_later
      end
    end
  end
end
