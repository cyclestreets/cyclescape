# frozen_string_literal: true

class SiteComment < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  after_initialize :set_user_details

  validates :body, presence: true
  validate :body_does_not_contain_spam
  validates :context_url, url: true
  normalize_attribute :context_url, with: :url

  def viewed?
    viewed_at
  end

  def viewed!
    self.viewed_at = Time.current
    save!
  end

  def cyclestreets_body
    URI.encode_www_form(
      type: "other",
      comments: body,
      url: context_url,
      name: name,
      email: email
    )
  end

  protected

  def set_user_details
    if user
      self.name = user.name
      self.email = user.email
    end
  end

  def body_does_not_contain_spam
    errors.add(:body, "The message cannot contain HTML.") unless body !~ %r{(<a ([^>]+)>|</a>|\[url\]|\[url=|\[/url\])}i
  end
end

# == Schema Information
#
# Table name: site_comments
#
#  id                      :integer          not null, primary key
#  body                    :text             not null
#  context_data            :text
#  context_url             :string(255)
#  cyclestreets_response   :jsonb
#  deleted_at              :datetime
#  email                   :string(255)
#  name                    :string(255)
#  sent_to_cyclestreets_at :datetime
#  viewed_at               :datetime
#  created_at              :datetime         not null
#  user_id                 :integer
#
# Indexes
#
#  index_site_comments_on_user_id  (user_id)
#
