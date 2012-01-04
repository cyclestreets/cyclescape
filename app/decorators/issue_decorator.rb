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

  protected

  def standard_photo_url
    photo.thumb("358x200>").url
  end
end
