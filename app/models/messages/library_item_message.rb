# == Schema Information
#
# Table name: library_item_messages
#
#  id              :integer         not null, primary key
#  thread_id       :integer         not null
#  message_id      :integer         not null
#  library_item_id :integer         not null
#

class LibraryItemMessage < MessageComponent
  belongs_to :item, class_name: "Library::Item", foreign_key: "library_item_id"

  validates_presence_of :item
end
