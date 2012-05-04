module MessageThreadsHelper
  MESSAGE_CONTROLLER_MAP = {
    "PhotoMessage" => "photos",
    "LinkMessage" => "links",
    "DeadlineMessage" => "deadlines",
    "LibraryItemMessage" => "library_items",
    "DocumentMessage" => "documents"
  }

  def thread_type(thread)
    if thread.private_to_committee?
      t(".group_committee", group: thread.group.name)
    elsif thread.private_to_group?
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

  def render_compact_threads_list(threads, options = {})
    defaults = {partial: "message_threads/compact", collection: threads, as: :thread}
    render defaults.merge(options)
  end

  def render_threads_list(threads, options = {})
    defaults = {partial: "message_threads/list", collection: threads, as: :thread}
    render defaults.merge(options)
  end

  def cannot_post?
    not permitted_to? :create, :messages
  end
end
