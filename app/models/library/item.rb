# frozen_string_literal: true


class Library::Item < ApplicationRecord
  include FakeDestroy
  include Taggable
  include Locatable

  searchable do
    text :search_text, :id
    text :tags do
      item.tags.map(&:name)
    end
  end

  belongs_to :component, polymorphic: true
  belongs_to :created_by, class_name: "User"
  has_and_belongs_to_many :tags, join_table: "library_item_tags", foreign_key: "library_item_id"
  has_many :library_item_messages, foreign_key: "library_item_id"
  has_many :threads, through: :library_item_messages

  scope :by_most_recent, -> { order("created_at DESC") }

  validates :created_by, presence: true

  delegate :title, to: :component
  delegate :searchable_text, to: :component

  protected

  def search_text
    searchable_text if component
  end
end

# == Schema Information
#
# Table name: library_items
#
#  id             :integer          not null, primary key
#  component_type :string(255)
#  deleted_at     :datetime
#  location       :geometry({:srid= geometry, 4326
#  created_at     :datetime         not null
#  updated_at     :datetime
#  component_id   :integer
#  created_by_id  :integer          not null
#
# Indexes
#
#  index_library_items_on_component_id_and_component_type  (component_id,component_type)
#  index_library_items_on_created_by_id                    (created_by_id)
#  index_library_items_on_location                         (location) USING gist
#
