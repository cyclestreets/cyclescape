require 'spec_helper'

describe GroupMembershipRequest do
  describe "newly created" do
    subject { GroupMembershipRequest.new }

    it "must have a group" do
      subject.should have(1).error_on(:group)
    end

    it "must have a user" do
      subject.should have(1).error_on(:user)
    end

    it "must be pending" do
      subject.status.should eql("pending")
    end
  end

  describe "to be valid" do
    subject { GroupMembershipRequest.new }
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }

    it "needs a user and a group" do
      subject.should_not be_valid
      subject.group = group
      subject.user = user
      subject.should be_valid
    end
  end

  context "pending request" do
    subject { FactoryGirl.create(:pending_gmr) }
    let(:boss) { FactoryGirl.create(:user) }

    it "can be cancelled" do
      subject.cancel
      subject.should be_valid
      subject.status.should eql("cancelled")
    end

    it "can be confirmed" do
      lambda { subject.confirm! }.should raise_error
      subject.actioned_by = boss
      lambda { subject.confirm! }.should_not raise_error
      subject.should be_valid
      subject.status.should eql("confirmed")
    end

    it "can be rejected" do
      lambda { subject.reject! }.should raise_error
      subject.actioned_by = boss
      lambda { subject.reject! }.should_not raise_error
      subject.should be_valid
      subject.status.should eql("rejected")
    end
  end

  context "check group creation" do
    subject { GroupMembershipRequest.new }
    let(:user) { FactoryGirl.create(:stewie) }
    let(:group) { FactoryGirl.create(:quahogcc) }
    let(:boss) { FactoryGirl.create(:brian) }

    it "should create group when confirmed" do
      user.should have(0).groups
      subject.user = user
      subject.group = group
      subject.actioned_by = boss
      subject.confirm.should be_true
      user.should have(1).groups
      user.groups[0].should eql(group)
    end
  end
end
