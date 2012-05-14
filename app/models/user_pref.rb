# == Schema Information
#
# Table name: user_prefs
#
#  id                                       :integer         not null, primary key
#  user_id                                  :integer         not null
#  notify_subscribed_threads                :boolean         default(TRUE), not null
#  notify_new_user_locations_issue          :boolean         default(FALSE), not null
#  notify_new_group_thread                  :boolean         default(TRUE), not null
#  notify_new_group_location_issue          :boolean         default(FALSE), not null
#  notify_new_user_locations_issue_thread   :boolean         default(FALSE), not null
#  subscribe_new_group_thread               :boolean         default(FALSE), not null
#  subscribe_new_user_location_issue_thread :boolean         default(FALSE), not null
#

class UserPref < ActiveRecord::Base
  belongs_to :user

  INVOLVEMENT_OPTIONS = %w(none notify subscribe)

  validates :involve_my_locations, inclusion: { in: INVOLVEMENT_OPTIONS }
  validates :involve_my_groups, inclusion: { in: INVOLVEMENT_OPTIONS }

  def notify_subscribed_threads!
    update_attribute(:notify_subscribed_threads, true)
  end
end
