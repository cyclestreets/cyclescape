# == Schema Information
#
# Table name: site_comments
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  name         :string(255)
#  email        :string(255)
#  body         :text            not null
#  context_url  :string(255)
#  context_data :text
#  created_at   :datetime        not null
#  viewed_at    :datetime
#

class SiteComment < ActiveRecord::Base
  belongs_to :user

  after_initialize :set_user_details

  validates :body, presence: true
  validates :context_url, url: true

  def viewed?
    viewed_at
  end

  def viewed!
    update_attribute(:viewed_at, Time.now)
  end

  protected

  def set_user_details
    if user
      self.name = user.name
      self.email = user.email
    end
  end
end
