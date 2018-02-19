# frozen_string_literal: true

# == Schema Information
#
# Table name: group_prefs
#
#  id                         :integer          not null, primary key
#  group_id                   :integer          not null
#  membership_secretary_id    :integer
#  notify_membership_requests :boolean          default(TRUE), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_group_prefs_on_group_id  (group_id) UNIQUE
#

class GroupPref < ActiveRecord::Base

  belongs_to :group
  belongs_to :membership_secretary, class_name: 'User'
end
