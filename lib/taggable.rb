# frozen_string_literal: true

module Taggable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def find_by_tags_from(taggable)
      includes(:tags).where(Tag.arel_table[:name].in(taggable.tags.map(&:name))).references(:tags)
    end

    def find_by_tag(tag)
      includes(:tags).where(Tag.arel_table[:name].eq(tag.name)).references(:tags)
    end

    def where_tag_names_in(tag_names)
      if tag_names.present?
        where(id: ids_with_all(tag_names, all: true))
      else
        none
      end
    end

    def where_tag_names_not_in(tag_names)
      if tag_names.present?
        where.not(id: ids_with_all(tag_names))
      else
        all
      end
    end

    private

    def ids_with_all(tag_names, opts = {})
      scope = joins(:tags).where(tags: { name: tag_names })
      if opts[:all]
        scope.group("issues.id").having("COUNT(tags.id)=?", tag_names.size)
      else
        scope.ids
      end
    end
  end

  def tags_string
    tags.map(&:name).join(", ")
  end

  def tags_string=(val)
    return unless val

    self.tags = tags_from_string(val)
  end

  def icon_from_tags
    if tags.loaded?
      tags.select(&:icon).min_by(&:name)&.icon
    else
      tags.where.not(icon: nil).order(:name).pluck(:icon).first
    end
  end

  protected

  def tags_from_string(val)
    val
      .delete("#!()[]{}")
      .split(/[,]+/)
      .map { |str| str.parameterize.gsub(" ", "-") }
      .uniq
      .delete_if { |str| str == "" }
      .map { |str| Tag.grab(str) }
  end
end
