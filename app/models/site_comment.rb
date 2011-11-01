class SiteComment < ActiveRecord::Base
  belongs_to :user

  validates :body, presence: true
  validates :context_url, url: true

  def viewed?
    viewed_at
  end

  def viewed!
    update_attribute(:viewed_at, Time.now)
  end
end
