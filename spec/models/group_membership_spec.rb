require 'spec_helper'

describe GroupMembership do
  describe "to be valid" do
    subject { GroupMembership.new }

    it "must belong to a group" do
      subject.should have(1).error_on(:group_id)
    end

    it "must belong to a user" do
      subject.should have(1).error_on(:user_id)
    end

    it "must have a role" do
      subject.should have(1).error_on(:role)
    end
  end

  describe "role" do
    subject { GroupMembership.new }

    it "may be 'committee'" do
      subject.role = "committee"
      subject.should have(0).errors_on(:role)
    end

    it "may be 'member'" do
      subject.role = "member"
      subject.should have(0).errors_on(:role)
    end

    it "may not be anything else" do
      subject.role = "chipmunk"
      subject.should have(1).error_on(:role)
    end
  end
end
