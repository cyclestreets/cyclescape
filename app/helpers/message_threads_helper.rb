module MessageThreadsHelper
  MESSAGE_CONTROLLER_MAP = {
    "PhotoMessage" => "photos",
    "LinkMessage" => "links",
    "DeadlineMessage" => "deadlines"
  }

  def thread_type(thread)
    if thread.private_to_group?
      t(".group_private", group: thread.group.name)
    elsif thread.group_id && thread.public?
      t(".group_public", group: thread.group.name)
    else
      t(".public")
    end
  end

  def message_controller_map(message)
    path = MESSAGE_CONTROLLER_MAP[message.class.to_s]
    raise "Message controller not found for #{message.class.to_s.inspect}" if path.nil?
    path
  end

  def message_truncate(message)
    truncate message.body, length: 90, separator: ".", omission: "\u2026"
  end

  def threads_list(threads, options = {})
    defaults = {partial: "message_threads/compact", collection: threads, as: :thread}
    render defaults.merge(options)
  end
end
