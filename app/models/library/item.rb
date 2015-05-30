class Library::Item < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  include FakeDestroy
  include Taggable

  acts_as_indexed fields: [:search]

  belongs_to :component, polymorphic: true
  belongs_to :created_by, class_name: 'User'
  has_and_belongs_to_many :tags, join_table: 'library_item_tags', foreign_key: 'library_item_id'
  has_many :library_item_messages, foreign_key: 'library_item_id'
  has_many :threads, through: :library_item_messages

  scope :by_most_recent, order('created_at DESC')

  validates_presence_of :created_by

  delegate :title, to: :component
  delegate :searchable_text, to: :component

  protected

  def search
    searchable_text if component
  end
end
