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

require 'spec_helper'

describe GroupPref do
  pending "add some examples to (or delete) #{__FILE__}"
end
