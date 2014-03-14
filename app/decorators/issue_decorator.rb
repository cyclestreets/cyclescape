class IssueDecorator < ApplicationDecorator
  decorates :issue

  def map
    h.render partial: "map", locals: { issue: issue }
  end

  def brief_description
    h.truncate issue.description, length: 90, separator: ".", omission: "\u2026"
  end

  def description
    h.auto_link h.simple_format issue.description
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

  def creator_link
    h.t "issues.compact.created_by_html", creator_link: h.link_to_profile(issue.created_by)
  end

  def tags_list
    h.render partial: "shared/tags/list", locals: { tags: issue.tags }
  end

  def thread_count
    issue.threads.count
  end

  def creation_time
    h.content_tag(:time, datetime: issue.created_at) do
      I18n.t("issues.show.issue_created_at", time_ago: h.time_ago_in_words(issue.created_at))
    end
  end

  def vote_count
    issue.plusminus
  end

  protected

  def standard_photo_url
    photo.thumb("358x200>").url
  end
end
