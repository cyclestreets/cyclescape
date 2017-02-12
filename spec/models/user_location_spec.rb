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
    let(:odd_polygon) { "POLYGON ((0.12258630664064392 52.215823843772895, 0.15657525927736685 52.23916655831, 0.1655016508789296 52.237905103703504, 0.16893487841799498 52.24284559612244, 0.17803293139650517 52.239061438462066, 0.18352609545899357 52.2461039177649, 0.18386941821289743 52.25156895227603, 0.20464044482423704 52.27331732010781, 0.23399454028322664 52.25619268644381, 0.2602587309570457 52.26932566542222, 0.2655802336425867 52.285080106279956, 0.2854929533691623 52.28823032243988, 0.2930460539551097 52.29526499648318, 0.2878962126464892 52.296839770456394, 0.29579263598633143 52.30439790611968, 0.2832613554687558 52.307651706141, 0.29459100634767243 52.31499811690052, 0.303002413818375 52.314263530689736, 0.295620974609384 52.3075467485829, 0.3036890593261827 52.30597235534511, 0.2969942656249993 52.29967422250579, 0.33184152514651327 52.288020314998, 0.32840829760743895 52.279304128216026, 0.3344164458007876 52.27436769581249, 0.3308115568847658 52.26701454316063, 0.2863512602539174 52.24242515009488, 0.25579553515626885 52.21929448331082, 0.2509890166015881 52.21719109778386, 0.20704370410155498 52.21140627394071, 0.19090753466799357 52.2096180850637, 0.14988046557618348 52.212247749683364, 0.1370058623046951 52.19278454535437, 0.14541726977539762 52.1720494903355, 0.13460260302736823 52.16678524766671, 0.1074801054687581 52.16267870598888, 0.10593515307618633 52.21603419328302, 0.1057634916992389 52.215718668644016, 0.12258630664064392 52.215823843772895)) " }
    let(:geom_collection) do
      "GEOMETRYCOLLECTION (#{line}, #{polygon})"
    end
    subject { build :user_location, location: geom_collection }

    it "works on geom collections" do
      expect(subject.buffered.area).to be_within(1e-8).of(0.014201500000000002)
    end

    it "works on polygons" do
      subject = build :user_location, location: odd_polygon
      expect(subject.buffered.area).to be > subject.location.area
    end
  end
end
