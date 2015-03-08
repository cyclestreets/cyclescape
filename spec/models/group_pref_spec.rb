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

require 'spec_helper'

describe GroupPref do
  it { is_expected.to belong_to(:group) }

  describe 'attributes' do
    booleans = %w(
      notify_membership_requests
      )

    booleans.each do |attr|
      it "should respond to #{attr} with true or false" do
        expect(subject.send(attr)).not_to be_nil
      end
    end
  end
end
