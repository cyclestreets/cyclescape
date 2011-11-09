class Library::Document < ActiveRecord::Base
  file_accessor :file

  belongs_to :item, class_name: "Library::Item", foreign_key: "library_item_id"
end
