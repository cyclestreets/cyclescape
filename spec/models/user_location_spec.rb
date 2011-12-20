# == Schema Information
#
# Table name: user_locations
#
#  id          :integer         not null, primary key
#  user_id     :integer         not null
#  category_id :integer         not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  location    :spatial({:srid=
#

require 'spec_helper'

describe UserLocation do
  describe "newly created" do
    subject { FactoryGirl.create(:user_location) }

    it "must have a user" do
      subject.user.should be_valid
    end

    it "must have a category" do
      subject.category.should be_valid
      subject.category.name.should be_a(String)
    end

    it "should have a geojson string" do
      subject.loc_json.should be_a(String)
      subject.loc_json.should eql(RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(subject.location)).to_json)
    end
  end

  describe "to be valid" do
    subject { FactoryGirl.build(:user_location) }

    it "must have a user" do
      subject.user = nil
      subject.should_not be_valid
    end

    it "must have a category" do
      subject.category = nil
      subject.should_not be_valid
    end

    it "must have a location" do
      subject.location = nil
      subject.should_not be_valid
    end

    it "must return an empty geojson string when no location" do
      subject.location = nil
      subject.loc_json.should be_a(String)
      subject.loc_json.should eq("")
    end

    it "should accept a valid geojson string" do
      subject.location = nil
      subject.should_not be_valid
      subject.loc_json = '{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.14,52.27]}}'
      subject.should be_valid
      subject.location.x.should eql(0.14)
      subject.location.y.should eql(52.27)
    end

    it "should ignore a bogus geojson string" do
      subject.loc_json = 'Garbage'
      subject.should be_valid
    end
  end

  context "overlapping groups" do
    subject { FactoryGirl.create(:user_location) }
    let(:small_group_profile) { FactoryGirl.create(:small_group_profile) }
    let(:big_group_profile) { FactoryGirl.create(:big_group_profile) }

    it "should identify the correct overlapping groups" do
      big_group_profile
      small_group_profile
      subject.overlapping_groups.should include(big_group_profile.group)
      subject.overlapping_groups.should_not include(small_group_profile.group)
    end
  end
end
