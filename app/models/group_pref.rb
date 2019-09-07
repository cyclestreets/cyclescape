# frozen_string_literal: true


class GroupPref < ApplicationRecord
  belongs_to :group
  belongs_to :membership_secretary, class_name: "User"
end

# == Schema Information
#
# Table name: group_prefs
#
#  id                         :integer          not null, primary key
#  notify_membership_requests :boolean          default(TRUE), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  group_id                   :integer          not null
#  membership_secretary_id    :integer
#
# Indexes
#
#  index_group_prefs_on_group_id                 (group_id) UNIQUE
#  index_group_prefs_on_membership_secretary_id  (membership_secretary_id)
#
