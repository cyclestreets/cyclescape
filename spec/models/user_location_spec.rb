# == Schema Information
#
# Table name: user_locations
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  category_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location    :spatial          geometry, 4326
#
# Indexes
#
#  index_user_locations_on_location  (location)
#  index_user_locations_on_user_id   (user_id)
#

require 'spec_helper'

describe UserLocation do
  describe 'newly created' do
    subject { FactoryGirl.create(:user_location) }

    it 'must have a user' do
      expect(subject.user).to be_valid
    end

    it 'must have a category' do
      expect(subject.category).to be_valid
      expect(subject.category.name).to be_a(String)
    end

    it 'should have a geojson string' do
      expect(subject.loc_json).to be_a(String)
      expect(subject.loc_json).to eql(RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(subject.location)).to_json)
    end
  end

  describe 'to be valid' do
    subject { FactoryGirl.build(:user_location) }

    it 'must have a user' do
      subject.user = nil
      expect(subject).not_to be_valid
    end

    it 'must have a category' do
      subject.category = nil
      expect(subject).not_to be_valid
    end

    it 'must have a location' do
      subject.location = nil
      expect(subject).not_to be_valid
    end

    it 'must return an empty geojson string when no location' do
      subject.location = nil
      expect(subject.loc_json).to be_a(String)
      expect(subject.loc_json).to eq('')
    end

    it 'should accept a valid geojson string' do
      subject.location = nil
      expect(subject).not_to be_valid
      subject.loc_json = '{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.14,52.27]}}'
      expect(subject).to be_valid
      expect(subject.location.x).to eql(0.14)
      expect(subject.location.y).to eql(52.27)
    end

    it 'should ignore a bogus geojson string' do
      subject.loc_json = 'Garbage'
      expect(subject).to be_valid
    end
  end

  context 'overlapping groups' do
    subject { FactoryGirl.create(:user_location) }
    let(:small_group_profile) { FactoryGirl.create(:small_group_profile) }
    let(:big_group_profile) { FactoryGirl.create(:big_group_profile) }

    it 'should identify the correct overlapping groups' do
      big_group_profile
      small_group_profile
      expect(subject.overlapping_groups).to include(big_group_profile.group)
      expect(subject.overlapping_groups).not_to include(small_group_profile.group)
    end
  end
end
