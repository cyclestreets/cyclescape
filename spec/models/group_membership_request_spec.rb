# == Schema Information
#
# Table name: group_membership_requests
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  group_id       :integer          not null
#  status         :string(255)      not null
#  actioned_by_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  message        :text
#
# Indexes
#
#  index_group_membership_requests_on_group_id  (group_id)
#  index_group_membership_requests_on_user_id   (user_id)
#

require 'spec_helper'

describe GroupMembershipRequest do
  describe 'newly created' do
    subject { GroupMembershipRequest.new }

    it 'must have a group' do
      expect(subject).to have(1).error_on(:group)
    end

    it 'must have a user' do
      expect(subject).to have(1).error_on(:user)
    end

    it 'must be pending' do
      expect(subject.status).to eql('pending')
    end

    it 'has an optional message' do
      expect(subject).to have(0).error_on(:message)
    end
  end

  describe 'to be valid' do
    subject { GroupMembershipRequest.new }
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }

    it 'needs a user and a group' do
      expect(subject).not_to be_valid
      subject.group = group
      subject.user = user
      expect(subject).to be_valid
    end
  end

  context 'pending request' do
    subject { FactoryGirl.create(:pending_gmr) }
    let(:boss) { FactoryGirl.create(:user) }

    it 'can be cancelled' do
      subject.cancel
      expect(subject).to be_valid
      expect(subject.status).to eql('cancelled')
    end

    it 'can be confirmed' do
      expect { subject.confirm! }.to raise_error
      subject.actioned_by = boss
      expect { subject.confirm! }.not_to raise_error
      expect(subject).to be_valid
      expect(subject.status).to eql('confirmed')
    end

    it 'can be rejected' do
      expect { subject.reject! }.to raise_error
      subject.actioned_by = boss
      expect { subject.reject! }.not_to raise_error
      expect(subject).to be_valid
      expect(subject.status).to eql('rejected')
    end
  end

  context 'check group creation' do
    subject { GroupMembershipRequest.new }
    let(:user) { FactoryGirl.create(:stewie) }
    let(:group) { FactoryGirl.create(:quahogcc) }
    let(:boss) { FactoryGirl.create(:brian) }

    it 'should create group when confirmed' do
      expect(user.groups.size).to eq(0)
      subject.user = user
      subject.group = group
      expect { subject.confirm! }.to raise_error
      expect(user.groups.size).to eq(0)

      subject.actioned_by = boss
      expect(subject.confirm).to be_truthy
      expect(user.groups.size).to eq(1)
      expect(user.groups[0]).to eql(group)
    end
  end

end
