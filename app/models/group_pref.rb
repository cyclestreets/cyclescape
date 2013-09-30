# == Schema Information
#
# Table name: group_prefs
#
#  id                         :integer          not null, primary key
#  group_id                   :integer          not null
#  membship_secretary_id      :integer
#  notify_membership_requests :boolean          default(TRUE), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class GroupPref < ActiveRecord::Base
  attr_accessible :membership_secretary, :notify_membership_requests

  belongs_to :group
  belongs_to :membership_secretary, class_name: "User"
end
