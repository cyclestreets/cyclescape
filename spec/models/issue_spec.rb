require 'spec_helper'

describe Issue do
  describe "newly created" do
    subject { FactoryGirl.create(:issue) }

    it "must have a created_by user" do
      subject.created_by.should be_valid
    end

    it "should have an centre x" do
      subject.centre.x.should be_a(Float)
    end

    it "should have longitudes for x" do
      subject.centre.x.should < 181
      subject.centre.x.should > -181
    end

    it "should have latitudes for y" do
      subject.centre.y.should < 90
      subject.centre.y.should > -90
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

    it "must have a description" do
      subject.description = nil
      subject.should_not be_valid
    end

    it "must have a location " do
      subject.location = nil
      subject.should_not be_valid
    end
  end
end
