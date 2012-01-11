module Taggable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def find_by_tags_from(taggable)
      tags = Arel::Table.new(:tags)
      includes(:tags).where(tags[:name].in(taggable.tags.map{ |t| t.name}))
    end
  end

  def tags_string
    tags.map(&:name).join(" ")
  end

  def tags_string=(val)
    self.tags = tags_from_string(val)
  end

  protected

  def tags_from_string(val)
    val.
      delete("#!()[]{}").
      split(/[,; ]+/).
      map {|str| Tag.grab(str) }
  end
end
