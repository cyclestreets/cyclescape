module Taggable
  def tags_string
    tags.map(&:name).join(" ")
  end

  def tags_string=(val)
    self.tags = tags_from_string(val)
  end

  protected

  def tags_from_string(val)
    val.split.map {|str| Tag.grab(str) }
  end
end
