# frozen_string_literal: true

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
    if profile.website.blank?
      h.t("user.profiles.show.no_website")
    else
      h.link_to profile.website, profile.website, rel: :nofollow
    end
  end

  def picture_standard_image
    if profile.picture
      h.image_tag picture_standard_url, alt: "",
                                        title: h.t("user.profiles.show.profile_picture_title", name: name),
                                        class: "profile-pic"
    end
  end

  def thumbnail_image
    if profile.picture
      h.image_tag picture_thumbnail_url, alt: "", title: h.t("user.profiles.edit.my_current_thumbnail_title")
    end
  end

  def picture_standard_url
    profile.picture.thumb("210x210>").url
  end

  def picture_thumbnail_url
    profile.picture.thumb("50x50>").url
  end

  def group_memberships
    return h.t("user.profiles.show.no_groups") if user.memberships.empty?

    items = user.memberships.map do |membership|
      h.link_to_profile(membership.group) + " (#{I18n.t('group_membership_roles.' + membership.role)})"
    end
    h.content_tag(:ul) do
      items.map { |i| h.content_tag(:li, i) }.join.html_safe
    end
  end
end
