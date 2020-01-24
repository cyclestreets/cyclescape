# frozen_string_literal: true

class LibraryItemMessage < MessageComponent
  belongs_to :item, class_name: "Library::Item", foreign_key: "library_item_id"
  belongs_to :thread, class_name: "MessageThread", foreign_key: "thread_id"

  validates :item, presence: true
end

# == Schema Information
#
# Table name: library_item_messages
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  created_by_id   :integer
#  library_item_id :integer          not null
#  message_id      :integer          not null
#  thread_id       :integer          not null
#
# Indexes
#
#  index_library_item_messages_on_created_by_id                  (created_by_id)
#  index_library_item_messages_on_library_item_id                (library_item_id)
#  index_library_item_messages_on_library_item_id_and_thread_id  (library_item_id,thread_id)
#  index_library_item_messages_on_message_id                     (message_id)
#  index_library_item_messages_on_thread_id                      (thread_id)
#
