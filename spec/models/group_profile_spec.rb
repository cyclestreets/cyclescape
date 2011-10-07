require 'spec_helper'

describe GroupProfile do
  describe "to be valid" do
    subject { FactoryGirl.create(:group_profile) }

    it "can have a blank description" do
      subject.description = nil
      subject.should be_valid
    end

    it "can have a blank location" do
      subject.location = nil
      subject.should be_valid
    end

    it "should accept a valid geojson string" do
      subject.location = nil
      subject.loc_json = '{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.14,52.27]}}'
      subject.should be_valid
      subject.location.x.should eql(0.14)
      subject.location.y.should eql(52.27)
    end

    it "should ignore a bogus geojson string" do
      subject.location = nil
      subject.loc_json = 'Garbage'
      subject.should be_valid
      subject.location.should be_nil
    end
  end
end
