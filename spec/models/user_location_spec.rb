# frozen_string_literal: true

require "spec_helper"

describe UserLocation do
  describe "newly created" do
    subject { create(:user_location) }

    it "should have a geojson string" do
      expect(subject.loc_json).to be_a(String)
      expect(subject.loc_json).to eql(RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(subject.location)).to_json)
    end
  end

  describe "to be valid" do
    subject { build(:user_location) }

    it "must have a user" do
      subject.user = nil
      expect(subject).not_to be_valid
    end

    it "must have a location" do
      subject.location = nil
      expect(subject).not_to be_valid
    end

    it "must have a non empty location" do
      subject.loc_json = "{\"type\":\"FeatureCollection\",\"features\":[]}"
      expect(subject).not_to be_valid
    end

    it "must return an empty geojson string when no location" do
      subject.location = nil
      expect(subject.loc_json).to be_a(String)
      expect(subject.loc_json).to eq("")
    end

    it "should accept a valid geojson string" do
      subject.location = nil
      expect(subject).not_to be_valid
      subject.loc_json = '{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.14,52.27]}}'
      expect(subject).to be_valid
      expect(subject.location.x).to eql(0.14)
      expect(subject.location.y).to eql(52.27)
    end

    it "should ignore a bogus geojson string" do
      subject.loc_json = "Garbage"
      expect(subject).to be_valid
    end

    it "apporves the user" do
      user = create(:user, approved: false)
      subject.user = user
      subject.save!
      expect(user.reload.approved).to eq true
    end
  end

  describe "buffered" do
    let(:line) { "LINESTRING (0 0, 0 2)" }
    let(:polygon) { "POLYGON ((0 0, 0 0.1, 0.1 0.1, 0.1 0, 0 0))" }
    let(:odd_polygon) { "POLYGON ((0.12258630664064392 52.215823843772895, 0.29579263598633143 52.30439790611968, 0.1074801054687581 52.16267870598888, 0.10593515307618633 52.21603419328302, 0.1057634916992389 52.215718668644016, 0.12258630664064392 52.215823843772895)) " }
    let(:geom_collection) do
      "GEOMETRYCOLLECTION (#{line}, #{polygon})"
    end
    let(:strange_geom_collection) do
      "GEOMETRYCOLLECTION (POLYGON ((-3.788091732031289 55.28171639104471, -3.282720638281247 55.01017018336803, -4.351141048437512 54.8476193969965, -3.788091732031289 55.28171639104471)), POLYGON ((-4.11245981848872 55.305395022157526, -3.5630216447403713 54.90747510684706, -5.182749306205093 54.91177262081619, -4.11245981848872 55.305395022157526)))"
    end
    subject { build :user_location, location: geom_collection }

    it "works on geom collections" do
      expect(subject.buffered.area).to be > subject.location.buffer(0.000001).area
    end

    it "works on polygons" do
      subject = build :user_location, location: odd_polygon
      expect(subject.buffered.area).to be > subject.location.area
    end

    it "makes location's valid" do
      subject = build :user_location, location: odd_polygon
      expect(subject.location).to_not be_valid
      subject.save
      expect(subject.reload.location).to be_valid
    end

    it "works on strange geom collections" do
      subject = build :user_location, location: strange_geom_collection
      expect(subject.buffered.buffer(0.000001).area).to be > subject.location.buffer(0.000001).area
    end
  end
end
