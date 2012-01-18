class IssueDecorator < ApplicationDecorator
  decorates :issue

  def map
    h.render partial: "map", locals: {issue: issue}
  end

  def description
    h.simple_format issue.description
  end

  def standard_photo_image
    return "" if photo.nil?
    h.image_tag standard_photo_url, class: "issue-photo"
  end

  def small_icon_path(default=true)
    icon_path("s", default)
  end

  def medium_icon_path(default=true)
    icon_path("m", default)
  end

  def large_icon_path(default=true)
    icon_path("l", default)
  end

  def tip_icon_path(default=true)
    icon_path("tip", default)
  end

  def icon_path(size, default=true)
    icon = nil
    icon ||= icon_from_tags
    icon ||= "misc" if default
    return "" if icon.nil?
    h.image_path "map-icons/#{size}-#{icon}.png"
  end

  protected

  def standard_photo_url
    photo.thumb("358x200>").url
  end
end
