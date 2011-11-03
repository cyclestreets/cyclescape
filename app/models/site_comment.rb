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
