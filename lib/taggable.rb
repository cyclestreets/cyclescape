module Taggable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def find_by_tags_from(taggable)
      tags = Arel::Table.new(:tags)
      includes(:tags).where(tags[:name].in(taggable.tags.map { |t| t.name })).references(:tags)
    end

    def find_by_tag(tag)
      tags = Arel::Table.new(:tags)
      includes(:tags).where(tags[:name].eq(tag.name)).references(:tags)
    end

    def where_tag_names_in(tag_names)
      if tag_names.present? &&
        ids = joins(:tags).where(tags: {name: tag_names}).group('issues.id').having('COUNT(tags.id)=?', tag_names.size)
        where(id: ids)
      else
        none
      end
    end
  end

  def tags_string
    tags.map(&:name).join(', ')
  end

  def tags_string=(val)
    self.tags = tags_from_string(val)
  end

  def icon_from_tags
    tag = tags.order('name').detect { |t| t.icon }
    tag.icon if tag
  end

  protected

  def tags_from_string(val)
    val.
      delete('#!()[]{}').
      split(/[,; ]+/).
      map { |str| str.parameterize }.
      uniq.
      delete_if { |str| str == '' }.
      map { |str| Tag.grab(str) }
  end
end
