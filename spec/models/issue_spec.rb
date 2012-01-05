# == Schema Information
#
# Table name: issues
#
#  id            :integer         not null, primary key
#  created_by_id :integer         not null
#  title         :string(255)     not null
#  description   :text            not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  deleted_at    :datetime
#  location      :spatial({:srid=
#

require 'spec_helper'

describe Issue do
  it_should_behave_like "a taggable model"

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

    it "should have a geojson string" do
      subject.loc_json.should be_a(String)
      subject.loc_json.should eql(RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(subject.location)).to_json)
    end

    it "should have a geojson feature representation" do
      subject.loc_feature.should be_a(RGeo::GeoJSON::Feature)
      subject.loc_feature.should eql(RGeo::GeoJSON::Feature.new(subject.location))
      subject.loc_feature.geometry.should_not be_nil
    end

    it "should accept properties for feature" do
      # see https://github.com/dazuma/rgeo-geojson/issues/5 for an RGeo bug that affects this test
      # When fixed, the hash should be {foo: "bar") since that's how we call it in the main code.
      f = subject.loc_feature({"foo" => "bar"})
      f.properties.should_not be_nil
      f.property("foo").should eql("bar")
    end

    it "should have no votes" do
      subject.votes_count.should be(0)
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

    it "should not be deleted" do
      subject.deleted_at.should be_nil
    end
  end

  describe "threads" do
    context "new thread" do
      subject { FactoryGirl.create(:issue) }

      it "should set the title to be the same as the issue" do
        thread = subject.threads.build
        thread.title.should == subject.title
      end

      it "should set the privacy to public by default" do
        thread = subject.threads.build
        thread.should be_public
      end
    end
  end

  describe "intersects" do
    context "should accept a variety of geometry types" do
      subject { FactoryGirl.create(:issue) }
      let(:factory) { RGeo::Geos::Factory.new(srid: 4326) }

      it "should accept a point" do
        geom = factory.parse_wkt('POINT(-1 1)')
        lambda { Issue.intersects(geom).all }.should_not raise_error
      end

      it "should accept a multipolygon" do
        geom2 = factory.parse_wkt('MULTIPOLYGON (((0.0 0.0, 0.0 1.0, 1.0 1.0, 0.0 0.0)), ((0.0 4.0, 0.0 5.0, 1.0 5.0, 0.0 4.0)))')
        lambda { Issue.intersects(geom2).all }.should_not raise_error
      end
    end
  end

  describe "find with index (search)" do
    subject { FactoryGirl.create(:issue) }

    it "should return the issue on title search" do
      subject
      results = Issue.find_with_index(subject.title)
      results.should include(subject)
    end

    it "should return the issue on a description search" do
      subject
      results = Issue.find_with_index(subject.description)
      results.should include(subject)
    end

    it "should match partial searches" do
      subject
      results = Issue.find_with_index(subject.description.split[0])
      results.should include(subject)
      results = Issue.find_with_index(subject.description.split[-1])
      results.should include(subject)
    end

    it "should not find gobbledy-gook" do
      subject
      results = Issue.find_with_index("asdfasdf12354")
      results.should be_empty
    end
  end

  describe "destroyed" do
    subject { FactoryGirl.create(:issue) }

    before do
      subject.destroy
    end

    it "shouldn't really destroy" do
      subject.should be_valid
      subject.deleted_at.should_not be_nil
    end

    it "shouldn't appear on a normal find" do
      Issue.all.should_not include(subject)
    end

    it "should appear when the default scope is removed" do
      Issue.unscoped.should include(subject)
    end
  end

  describe "votes" do
    subject { FactoryGirl.create(:issue) }
    let(:brian) { FactoryGirl.create(:brian) }
    let(:meg) { FactoryGirl.create(:meg) }

    it "should allow upvoting" do
      brian.vote_for(subject)
      subject.votes_count.should eql(1)
      subject.votes_for.should eql(1)
      subject.votes_against.should eql(0)
    end

    it "should allow downvoting" do
      brian.vote_against(subject)
      subject.votes_against.should eql(1)
    end

    it "should not allow duplicate votes" do
      brian.vote_for(subject)
      lambda { brian.vote_for(subject) }.should raise_error
    end

    it "should allow a change of vote" do
      brian.vote_against(subject)
      brian.vote_exclusively_for(subject)
      subject.votes_count.should eql(1)
      subject.votes_for.should eql(1)
      subject.votes_against.should eql(0)
    end

    it "should give a plusminus summary" do
      brian.vote_for(subject)
      meg.vote_for(subject)
      subject.plusminus.should eql(2)
      meg.vote_exclusively_against(subject)
      subject.plusminus.should eql(0)
      brian.vote_exclusively_against(subject)
      subject.plusminus.should eql(-2)
    end
  end
end
