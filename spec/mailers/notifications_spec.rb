require 'spec_helper'

describe Notifications do
  let(:group)         { group_profile.group }
  let(:user)          { gm.user }
  let!(:gm)           { create :group_membership, group: group }
  let(:group_profile) { create :group_profile, new_user_email: "big hello to {{full_name}} nothing to {{see}} here" }

  it 'interpolates the {{full_name}} only' do
    subject = described_class.send(:added_to_group, gm)
    expect(subject.body).to include("big hello to #{user.full_name} nothing to  here")
  end
end
