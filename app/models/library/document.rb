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
  file_accessor :file do
    storage_path :generate_file_path
  end

  attr_accessor :created_by

  belongs_to :item, class_name: "Library::Item", foreign_key: "library_item_id"

  scope :recent, lambda {|num| includes(:item).order("library_items.created_at DESC").limit(num) }

  before_create :create_library_item, unless: :item
  after_create :update_library_item

  validate :created_by, presence: true

  protected

  def create_library_item
    item = build_item(created_by: created_by)
    item.save!
    self.item = item
  end

  def update_library_item
    self.item.update_attributes(component: self)
  end

  def generate_file_path
    hash = Digest::SHA1.file(file.path).hexdigest
    "library/documents/#{hash[0..2]}/#{hash[3..5]}/#{hash}"
  end
end
