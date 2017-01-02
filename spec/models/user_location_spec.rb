require 'spec_helper'

describe UserLocation do
  describe 'newly created' do
    subject { create(:user_location) }

    it 'must have a user' do
      expect(subject.user).to be_valid
    end

    it 'should have a geojson string' do
      expect(subject.loc_json).to be_a(String)
      expect(subject.loc_json).to eql(RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(subject.location)).to_json)
    end
  end

  describe 'to be valid' do
    subject { build(:user_location) }

    it 'must have a user' do
      subject.user = nil
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
    subject { create(:user_location) }
    let(:small_group_profile) { create(:small_group_profile) }
    let(:big_group_profile) { create(:big_group_profile) }

    it 'should identify the correct overlapping groups' do
      big_group_profile
      small_group_profile
      expect(subject.overlapping_groups).to include(big_group_profile.group)
      expect(subject.overlapping_groups).not_to include(small_group_profile.group)
    end
  end

  describe "buffered" do
    let(:line) { 'LINESTRING (0 0, 0 2)' }
    let(:polygon) { 'POLYGON ((0 0, 0 0.1, 0.1 0.1, 0.1 0, 0 0))' }
    let(:geom_collection) do
      "GEOMETRYCOLLECTION (#{line}, #{polygon})"
    end
    subject { build :user_location, location: geom_collection }

    it "works on geom collections" do
      expect(subject.buffered.area).to be_within(1e-8).of(0.014201500000000002)
    end
  end
end
