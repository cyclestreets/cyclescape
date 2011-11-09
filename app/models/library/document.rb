# == Schema Information
#
# Table name: library_documents
#
#  id              :integer         not null, primary key
#  library_item_id :integer         not null
#  title           :string(255)     not null
#  file_uid        :string(255)
#  file_name       :string(255)
#  file_size       :integer
#

class Library::Document < ActiveRecord::Base
  file_accessor :file

  belongs_to :item, class_name: "Library::Item", foreign_key: "library_item_id"
end
