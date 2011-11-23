module TagsHelper
  def render_tags(context)
    context.tags.map(&:name).join(" ")
  end
end
