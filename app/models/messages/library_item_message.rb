class LibraryItemMessage < MessageComponent
  belongs_to :item, class_name: "Library::Item", foreign_key: "library_item_id"

  validates_presence_of :item
end
