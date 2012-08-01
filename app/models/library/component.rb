# Base class for implementing components of Library Items.
class Library::Component < ActiveRecord::Base
  self.abstract_class = true

  attr_accessor :created_by

  belongs_to :item, class_name: "Library::Item", foreign_key: "library_item_id"

  scope :recent, lambda {|num| includes(:item).order("library_items.created_at DESC").limit(num) }

  before_create :create_library_item, unless: :item
  after_create :update_library_item

  validate :created_by, presence: true

  def created_by
    @created_by || item && item.created_by
  end

  def created_at
    item && item.created_at
  end

  protected

  def create_library_item
    item = build_item
    item.created_by = created_by
    item.save!
    self.item = item
  end

  def update_library_item
    self.item.update_attributes(component: self)
    self.item.update_index
  end
end
