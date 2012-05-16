# == Schema Information
#
# Table name: user_prefs
#
#  id                      :integer         not null, primary key
#  user_id                 :integer         not null
#  involve_my_locations    :string(255)     default("subscribe"), not null
#  involve_my_groups       :string(255)     default("notify"), not null
#  involve_my_groups_admin :boolean         default(FALSE), not null
#  enable_email            :boolean         default(FALSE), not null
#

class UserPref < ActiveRecord::Base
  belongs_to :user

  INVOLVEMENT_OPTIONS = %w(none notify subscribe)

  validates :involve_my_locations, inclusion: { in: INVOLVEMENT_OPTIONS }
  validates :involve_my_groups, inclusion: { in: INVOLVEMENT_OPTIONS }
end
