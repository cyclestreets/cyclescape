# == Schema Information
#
# Table name: user_prefs
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  involve_my_locations    :string(255)      default("subscribe"), not null
#  involve_my_groups       :string(255)      default("notify"), not null
#  involve_my_groups_admin :boolean          default(FALSE), not null
#  enable_email            :boolean          default(FALSE), not null
#
# Indexes
#
#  index_user_prefs_on_enable_email             (enable_email)
#  index_user_prefs_on_involve_my_groups        (involve_my_groups)
#  index_user_prefs_on_involve_my_groups_admin  (involve_my_groups_admin)
#  index_user_prefs_on_involve_my_locations     (involve_my_locations)
#  index_user_prefs_on_user_id                  (user_id) UNIQUE
#

class UserPref < ActiveRecord::Base
  attr_accessible :involve_my_locations, :involve_my_groups, :involve_my_groups_admin, :enable_email, :profile_visibility

  belongs_to :user

  INVOLVEMENT_OPTIONS = %w(none notify subscribe)
  PROFILE_OPTIONS = %w(public group)

  validates :involve_my_locations, inclusion: { in: INVOLVEMENT_OPTIONS }
  validates :involve_my_groups, inclusion: { in: INVOLVEMENT_OPTIONS }
  validates :profile_visibility, inclusion: { in: PROFILE_OPTIONS }
end
