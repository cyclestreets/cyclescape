class SearchUpdater
  def self.queue
    :search_updates
  end

  # Call +method+ with *args on ourself
  def self.perform(method, *args)
    send(method, *args)
  end

  def self.update_thread(thread)
    Resque.enqueue(SearchUpdater, :process_thread, thread.id)
  end

  def self.process_thread(thread_id)
    thread = MessageThread.find(thread_id)
    Sunspot.index thread
  end
end
