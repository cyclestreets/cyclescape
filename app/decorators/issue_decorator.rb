class IssueDecorator < ApplicationDecorator
  decorates :issue

  def standard_photo_image
    return "" if photo.nil?
    h.image_tag standard_photo_url, class: "issue-photo"
  end

  protected

  def standard_photo_url
    photo.thumb("358x200>").url
  end
end
