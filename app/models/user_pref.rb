class UserPref < ActiveRecord::Base
  belongs_to :user

  def notify_subscribed_threads!
    update_attribute(:notify_subscribed_threads, true)
  end
end
