require 'spec_helper'

describe GroupRequest do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:boss) { create(:user) }

  describe 'newly created' do
    it 'must have a user' do
      expect(subject).to have(1).error_on(:user)
      subject.user = user
      expect(subject).to have(0).error_on(:user)
    end

    it 'must be pending' do
      expect(subject.status).to eql('pending')
    end

    it 'has an optional message' do
      expect(subject).to have(0).error_on(:message)
    end

    it { is_expected.to allow_value('public').for(:default_thread_privacy) }
    it { is_expected.to allow_value('group').for(:default_thread_privacy) }
    it { is_expected.not_to allow_value('other').for(:default_thread_privacy) }
  end

  describe 'must not conflict with existing groups' do
    subject { create(:group_request) }

    it 'with its name' do
      subject.name = group.name
      expect(subject).to have(1).error_on(:name)
    end

    it 'with its short name' do
      subject.short_name = group.short_name
      expect(subject).to have(1).error_on(:short_name)
    end

    it 'with its email' do
      subject.email = group.email
      expect(subject).to have(1).error_on(:email)
    end

    it 'except when confirmed' do
      subject.actioned_by = boss
      subject.confirm!
      expect(subject).to be_valid
    end
  end

  context 'pending request' do
    subject { create(:group_request) }

    it 'can be cancelled' do
      subject.cancel
      expect(subject).to be_valid
      expect(subject.status).to eql('cancelled')
    end

    it 'can be confirmed' do
      expect { subject.confirm! }.to raise_error AASM::InvalidTransition
      subject.actioned_by = boss
      expect { subject.confirm! }.not_to raise_error
    end

    it 'can be rejected' do
      expect { subject.reject! }.to raise_error AASM::InvalidTransition
      subject.actioned_by = boss
      expect { subject.reject! }.not_to raise_error
      expect(subject).to be_valid
      expect(subject.status).to eql('rejected')
    end
  end

  context 'check group creation' do
    subject { create :group_request, user: user, actioned_by: boss}
    let(:boss) { create(:brian) }

    it 'should create group when confirmed' do
      expect(user.reload.groups.size).to eq(0)

      expect{subject.confirm}.to change{Group.count}.by(1)
      expect(Group.last.committee_members).to include(user)
    end
  end
end
