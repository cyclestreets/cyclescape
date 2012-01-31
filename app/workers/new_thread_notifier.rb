class NewThreadNotifier
  def self.queue
    :outbound_mail
  end

  def self.perform(method, *args)
    send(method, *args)
  end

  def self.notify_new_thread(thread)
    Resque.enqueue(NewThreadNotifier, :queue_new_thread, thread.id)
  end

  def self.queue_new_thread(thread_id)
    thread = MessageThread.find(thread_id)
    Resque.enqueue(NewThreadNotifier, :notify_new_group_thread, thread.id) if thread.group
  end

  def self.notify_new_group_thread(thread_id)
    thread = MessageThread.find(thread_id)
    members = thread.group.members.with_pref(:notify_new_group_thread)
    members.each do |member|
      Resque.enqueue(NewThreadNotifier, :send_new_group_thread_notification, thread.id, member.id)
    end
  end

  def self.send_new_group_thread_notification(thread_id, user_id)
    thread = MessageThread.find(thread_id)
    user = User.find(user_id)
    Notifications.new_group_thread(thread, user).deliver
  end
end
