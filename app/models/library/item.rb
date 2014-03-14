# == Schema Information
#
# Table name: library_items
#
#  id             :integer          not null, primary key
#  component_id   :integer
#  component_type :string(255)
#  created_by_id  :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime
#  deleted_at     :datetime
#  location       :spatial({:srid=>
#

class Library::Item < ActiveRecord::Base
  include FakeDestroy
  include Taggable

  attr_accessible :component, :tags_string

  acts_as_indexed fields: [:search]

  belongs_to :component, polymorphic: true
  belongs_to :created_by, class_name: "User"
  has_and_belongs_to_many :tags, join_table: "library_item_tags", foreign_key: "library_item_id"
  has_many :library_item_messages, foreign_key: "library_item_id"
  has_many :threads, through: :library_item_messages

  scope :by_most_recent, order("created_at DESC")

  validates_presence_of :created_by

  delegate :title, to: :component
  delegate :searchable_text, to: :component

  protected

  def search
    searchable_text if self.component
  end
end
