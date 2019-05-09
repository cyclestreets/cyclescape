# frozen_string_literal: true

# == Schema Information
#
# Table name: library_item_messages
#
#  id              :integer          not null, primary key
#  thread_id       :integer          not null
#  message_id      :integer          not null
#  library_item_id :integer          not null
#  created_by_id   :integer
#

class LibraryItemMessage < MessageComponent
  belongs_to :item, class_name: "Library::Item", foreign_key: "library_item_id"
  belongs_to :thread, class_name: "MessageThread", foreign_key: "thread_id"
  belongs_to :message

  validates :item, presence: true
end
