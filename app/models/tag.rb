# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id   :integer          not null, primary key
#  name :string(255)      not null
#  icon :string(255)
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#

class Tag < ApplicationRecord
  validates :name, presence: true
  has_and_belongs_to_many :issues, join_table: "issue_tags"
  has_and_belongs_to_many :threads, class_name: 'MessageThread', join_table: 'message_thread_tags', association_foreign_key: 'thread_id'
  has_and_belongs_to_many :library_items, class_name: 'Library::Item', join_table: 'library_item_tags', association_foreign_key: 'library_item_id'

  delegate :url_helpers, to: "Rails.application.routes"

  class << self
    def names
      all.map { |tag| tag.name }
    end

    def grab(val)
      find_or_create_by(name: normalise(val))
    end

    def top_tags_fresh(limit)
      joins('LEFT OUTER JOIN "message_thread_tags" ON "message_thread_tags"."tag_id" = "tags"."id"
          LEFT OUTER JOIN "message_threads" ON "message_threads"."id" = "message_thread_tags"."thread_id" AND "message_threads"."deleted_at" IS NULL
          LEFT OUTER JOIN "library_item_tags" ON "library_item_tags"."tag_id" = "tags"."id"
          LEFT OUTER JOIN "library_items" ON "library_items"."id" = "library_item_tags"."library_item_id"
          LEFT OUTER JOIN "issue_tags" ON "issue_tags"."tag_id" = "tags"."id"
          LEFT OUTER JOIN "issues" ON "issues"."id" = "issue_tags"."issue_id" AND "issues"."deleted_at" IS NULL').
          select(:id, :name, :icon,
                 'count(DISTINCT message_threads.id) + count(DISTINCT issues.id) + count(DISTINCT library_items.id)
               AS tag_count').
               group(:id, :name, :icon).
               order('tag_count DESC').
               limit(limit)
    end

    def top_tags(limit = 50)
      Rails.cache.fetch("Tag.top_tags", expires_in: 1.day) do
        Tag.top_tags_fresh(500).to_a
      end.first(limit)
    end
  end

  def name=(val)
    if val.is_a?(String)
      write_attribute(:name, self.class.normalise(val))
    end
  end

  def to_param
    name.parameterize
  end

  def as_json(*_)
    super.merge(
      url: url_helpers.tag_url(self, host: Rails.application.config.action_mailer.default_url_options[:host])
    )
  end

  protected

  def self.normalise(tag)
    tag.strip.downcase
  end
end
