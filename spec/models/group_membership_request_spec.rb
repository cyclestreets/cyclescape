# frozen_string_literal: true


require "spec_helper"

describe GroupMembershipRequest do
  describe "newly created" do
    subject { GroupMembershipRequest.new }

    it "must have a group" do
      expect(subject).to have(1).error_on(:group)
    end

    it "must have a user" do
      expect(subject).to have(1).error_on(:user)
    end

    it "must be pending" do
      expect(subject.status).to eql("pending")
    end

    it "has an optional message" do
      expect(subject).to have(0).error_on(:message)
    end
  end

  describe "to be valid" do
    subject { GroupMembershipRequest.new }
    let(:user)  { create(:user) }
    let(:group) { create(:group) }

    it "needs a user and a group" do
      expect(subject).not_to be_valid
      subject.group = group
      subject.user = user
      expect(subject).to be_valid
    end
  end

  context "pending request" do
    subject { create(:pending_gmr) }
    let(:boss) { create(:user) }

    it "can be cancelled" do
      subject.cancel
      expect(subject).to be_valid
      expect(subject.status).to eql("cancelled")
    end

    it "can be confirmed" do
      expect { subject.confirm! }.to raise_error AASM::InvalidTransition
      subject.actioned_by = boss
      expect { subject.confirm! }.not_to raise_error
      expect(subject).to be_valid
      expect(subject.status).to eql("confirmed")
    end

    it "can be rejected" do
      expect { subject.reject! }.to raise_error AASM::InvalidTransition
      subject.actioned_by = boss
      expect { subject.reject! }.not_to raise_error
      expect(subject).to be_valid
      expect(subject.status).to eql("rejected")
    end
  end

  context "check group creation" do
    subject { GroupMembershipRequest.new(user: user, group: group) }
    let(:user) { create(:stewie, approved: false) }
    let(:group) { create(:quahogcc) }
    let(:boss) { create(:brian) }

    it "should create group when confirmed" do
      expect(user.groups.size).to eq(0)
      expect { subject.confirm! }.to raise_error AASM::InvalidTransition
      expect(user.groups.size).to eq(0)

      subject.actioned_by = boss
      expect(subject.confirm).to be_truthy
      expect(user.reload.groups.size).to eq(1)
      expect(user.groups[0]).to eql(group)
    end

    it "should approve user" do
      subject.actioned_by = boss
      expect { subject.confirm! }.to change { user.reload.approved }.from(false).to(true)
    end

    it "shouldn't fail if user is in group already" do
      user.memberships.create!(group: group, role: "member")
      subject.actioned_by = boss
      expect { subject.confirm! }.to_not raise_error
    end
  end
end
