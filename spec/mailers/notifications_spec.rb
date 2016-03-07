require 'spec_helper'

describe Notifications do
  let(:group)         { group_profile.group }
  let(:user)          { gm.user }
  let(:gm)            { create :group_membership, group: group }
  let(:group_profile) { create :group_profile, new_user_email: nil }

  describe 'added to group' do
    context 'with no email set' do
      it 'uses the default' do
        subject = described_class.send(:added_to_group, gm.reload)
        expect(subject.body).to include('has added you to their Cyclescape group')
        expect(subject.body).to include("#{group.short_name}.example.com")
      end
    end

    context 'with an email set' do
      before do
        gm.group.reload.profile.update!(
          new_user_email: "big hello to {{full_name}} nothing to {{see}} here")
      end

      it 'uses the overridden value' do
        subject = described_class.send(:added_to_group, gm)
        expect(subject.body).to include("big hello to #{user.full_name} nothing to  here")
      end
    end
  end
end

