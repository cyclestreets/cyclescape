# frozen_string_literal: true

# Base class for implementing components of Library Items.
class Library::Component < ApplicationRecord
  self.abstract_class = true

  attr_accessor :created_by, :loc_json
  attr_writer   :tags_string

  belongs_to :item, class_name: "Library::Item", foreign_key: "library_item_id"

  scope :recent, ->(num) { includes(:item).order("library_items.created_at DESC").limit(num) }

  before_create :create_library_item, unless: :item
  after_commit :update_library_item

  delegate :tags_string, :location, to: :item, allow_nil: true

  validates :created_by, presence: true

  def created_by
    @created_by || item&.created_by
  end

  # added for auth checks
  def created_by_id
    created_by&.id
  end

  def created_at
    item&.created_at
  end

  protected

  def create_library_item
    item = build_item(created_by: created_by, tags_string: @tags_string, loc_json: @loc_json)
    item.save!
    self.item = item
  end

  def update_library_item
    return unless item

    item.update(tags_string: @tags_string, loc_json: @loc_json, component: self)
    Sunspot.index item
    Sunspot.commit
  end
end
