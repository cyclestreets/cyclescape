require 'spec_helper'

describe Issue do
  describe "newly created" do
    subject { FactoryGirl.create(:issue) }

    it "must have a created_by user" do
      subject.created_by.should be_valid
    end
  end

  describe "to be valid" do
    subject { FactoryGirl.create(:issue) }

    it "must have a title" do
      subject.title = ""
      subject.should_not be_valid
    end

    it "must have a created_by user" do
      subject.created_by = nil
      subject.should_not be_valid
    end
  end
end
