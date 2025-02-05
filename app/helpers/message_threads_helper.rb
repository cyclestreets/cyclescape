# frozen_string_literal: true

module MessageThreadsHelper
  MESSAGE_CONTROLLER_MAP = {
    "PhotoMessage" => "photos",
    "CyclestreetsPhotoMessage" => "cyclestreets_photos",
    "LinkMessage" => "links",
    "DeadlineMessage" => "deadlines",
    "LibraryItemMessage" => "library_items",
    "DocumentMessage" => "documents",
    "StreetViewMessage" => "street_views",
    "ThreadLeaderMessage" => "thread_leaders",
    "MapMessage" => "maps",
    "ActionMessage" => "actions",
    "PollMessage" => "polls"
  }.freeze

  MESSAGE_LIBRARY_MAP = {
    "PhotoMessage" => nil,
    "LinkMessage" => nil,
    "DeadlineMessage" => nil,
    "LibraryItemMessage" => nil,
    "DocumentMessage" => "document",
    "Message" => "note",
    "StreetViewMessage" => nil
  }.freeze

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

  def privacy_badge_title_text(thread:)
    if thread.private_to_committee?
      title = t "message_threads.show.private_to_committee_message_title", group: thread.group.name
      text = t "message_threads.show.private_to_committee_message_text"
    elsif thread.private_to_group?
      title = t "message_threads.show.private_to_group_message_title", group: thread.group.name
      text = t "message_threads.show.private_to_group_message_text"
    elsif thread.private_message?
      title = t "message_threads.show.private_html", creator: link_to_profile(thread.created_by), message_to: link_to_profile(thread.user)
      text = t "message_threads.show.private_text"
    else
      title = t "message_threads.show.public_message_title"
      text = t "message_threads.show.public_message_text"
    end

    [title, text]
  end

  def message_controller_map(message)
    path = MESSAGE_CONTROLLER_MAP[message.class.to_s]
    raise "Message controller not found for #{message.class.to_s.inspect}" if path.nil?

    path
  end

  def library_type_for(message)
    obj = message.component || message
    MESSAGE_LIBRARY_MAP[obj.class.to_s]
  end

  def render_compact_threads_list(threads, options = {})
    defaults = { partial: "message_threads/compact", collection: threads, as: :thread }
    render defaults.merge(options)
  end

  def render_threads_list(threads, options = {})
    defaults = { partial: "shared/message_threads_list", collection: threads, as: :thread }
    render defaults.merge(options)
  end

  def message_button_html
    {
      class: "btn-green", disabled: !current_user, data: { disable_with: t("formtastic.actions.saving") }
    }
  end
end
