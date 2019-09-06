# frozen_string_literal: true

require "spec_helper"

describe GroupMembership do
  it "deletes pending gmrs" do
    gmr = create :pending_gmr
    gmr.user.memberships.create!(group: gmr.group, role: "member")
    expect { gmr.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  describe "to be valid" do
    subject { GroupMembership.new }

    it "must belong to a group" do
      expect(subject).to have(1).error_on(:group)
    end

    it "must have a role" do
      subject.role = ""
      expect(subject).to have(1).error_on(:role)
    end
  end

  describe "role" do
    subject { GroupMembership.new }

    it "should default to member" do
      expect(subject.role).to eql("member")
    end

    it "may be 'committee'" do
      subject.role = "committee"
      expect(subject).to have(0).errors_on(:role)
    end

    it "may be 'member'" do
      subject.role = "member"
      expect(subject).to have(0).errors_on(:role)
    end

    it "may not be anything else" do
      subject.role = "chipmunk"
      expect(subject).to have(1).error_on(:role)
    end
  end
end
