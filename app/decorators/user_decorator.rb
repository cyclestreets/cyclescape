class UserDecorator < ApplicationDecorator
  decorates :user

  # Profile attributes

  def about
    h.simple_format profile.about
  end

  def website?
    user.profile.website?
  end

  def website_link
    h.link_to profile.website, profile.website, rel: :nofollow
  end

  def picture_standard_image
    if profile.picture
      h.image_tag picture_standard_url, alt: "", title: h.t("user.profiles.show.profile_picture_title", name: name)
    end
  end

  def thumbnail_image
    if profile.picture
      h.image_tag picture_thumbnail_url, alt: "", title: h.t("user.profiles.edit.my_current_thumbnail_title")
    end
  end

  def picture_standard_url
    profile.picture.thumb("250x250>").url
  end

  def picture_thumbnail_url
    profile.picture.thumb("50x50>").url
  end
end
