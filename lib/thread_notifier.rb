class ThreadNotifier
  def self.notify_subscribers(thread, type, message = nil)
    thread.subscribers.each do |subscriber|
      ThreadMailer.send(type, message, subscriber).deliver
    end
  end
end
