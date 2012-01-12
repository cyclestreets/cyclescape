# == Schema Information
#
# Table name: user_prefs
#
#  id                              :integer         not null, primary key
#  user_id                         :integer         not null
#  notify_subscribed_threads       :boolean         default(TRUE), not null
#  notify_new_home_locations_issue :boolean         default(FALSE), not null
#  notify_new_group_thread         :boolean         default(TRUE), not null
#  notify_new_issue_thread         :boolean         default(FALSE), not null
#

class UserPref < ActiveRecord::Base
  belongs_to :user

  def notify_subscribed_threads!
    update_attribute(:notify_subscribed_threads, true)
  end
end
