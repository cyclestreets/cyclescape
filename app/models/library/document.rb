class Library::Document < ActiveRecord::Base
  file_accessor :file

  belongs_to :item, class_name: "LibraryItem"
end
