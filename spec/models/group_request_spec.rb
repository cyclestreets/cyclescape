require 'spec_helper'

describe GroupRequest do
  let(:user) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group) }

  describe 'newly created' do
    subject { described_class.new }

    it 'must have a user' do
      expect(subject).to have(1).error_on(:user)
      subject.user = user
      expect(subject).to have(1).error_on(:user)
    end

    it 'must be pending' do
      expect(subject.status).to eql('pending')
    end

    it 'has an optional message' do
      expect(subject).to have(0).error_on(:message)
    end
  end

  describe 'must not conflict with current groups' do
    subject { FactoryGirl.create(:group_request) }

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
  end

  context 'pending request' do
    subject { FactoryGirl.create(:group_request) }
    let(:boss) { FactoryGirl.create(:user) }

    it 'can be cancelled' do
      subject.cancel
      expect(subject).to be_valid
      expect(subject.status).to eql('cancelled')
    end

    it 'can be confirmed' do
      binding.pry
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
    subject { described_class.new }
    let(:boss) { FactoryGirl.create(:brian) }

    it 'should create group when confirmed' do
      subject.user = user
      subject.actioned_by = boss
      expect(user.reload.groups.size).to eq(0)

      expect{subject.confirm}.to change{Group.size}.by(1)
      expect(Group.last.committee_members).to include(user)
    end
  end
end
