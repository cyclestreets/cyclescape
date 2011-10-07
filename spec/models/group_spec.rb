require 'spec_helper'

describe Group do
  describe "to be valid" do
    subject { FactoryGirl.build(:group) }

    it "must have a name" do
      subject.name = ""
      subject.should have(1).error_on(:name)
    end

    it "must have a short name" do
      subject.short_name = ""
      subject.should have(1).error_on(:short_name)
    end
  end

  describe "newly created" do
    subject { FactoryGirl.create(:group) }

    it "must have a profile" do
      subject.profile.should be_valid
    end
  end

  context "members" do
    let(:membership) { FactoryGirl.create(:brian_at_quahogcc) }
    let(:brian) { membership.user }

    subject { membership.group }

    it "should list committee members" do
      subject.committee_members.should include(brian)
    end
  end
end
