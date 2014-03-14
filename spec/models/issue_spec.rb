# == Schema Information
#
# Table name: issues
#
#  id            :integer          not null, primary key
#  created_by_id :integer          not null
#  title         :string(255)      not null
#  description   :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  location      :spatial({:srid=>
#  photo_uid     :string(255)
#

require 'spec_helper'

describe Issue do
  it_should_behave_like 'a taggable model'

  describe 'newly created' do
    subject { FactoryGirl.create(:issue) }

    it 'must have a created_by user' do
      subject.created_by.should be_valid
    end

    it 'should have an centre x' do
      subject.centre.x.should be_a(Float)
    end

    it 'should have longitudes for x' do
      subject.centre.x.should < 181
      subject.centre.x.should > -181
    end

    it 'should have latitudes for y' do
      subject.centre.y.should < 90
      subject.centre.y.should > -90
    end

    it 'should have a geojson string' do
      subject.loc_json.should be_a(String)
      subject.loc_json.should eql(RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(subject.location)).to_json)
    end

    it 'should have a geojson feature representation' do
      subject.loc_feature.should be_a(RGeo::GeoJSON::Feature)
      subject.loc_feature.should eql(RGeo::GeoJSON::Feature.new(subject.location))
      subject.loc_feature.geometry.should_not be_nil
    end

    it 'should accept properties for feature' do
      f = subject.loc_feature(foo: 'bar')
      f.properties.should_not be_nil
      f.property(:foo).should eql('bar')
    end

    it 'should have no votes' do
      subject.votes_count.should be(0)
    end
  end

  describe 'to be valid' do
    subject { FactoryGirl.create(:issue) }

    it 'must have a title' do
      subject.title = ''
      subject.should_not be_valid
    end

    it 'must have a created_by user' do
      subject.created_by = nil
      subject.should_not be_valid
    end

    it 'must have a description' do
      subject.description = nil
      subject.should_not be_valid
    end

    it 'must have a location' do
      subject.location = nil
      subject.should_not be_valid
    end

    it 'must return an empty geojson string when no location' do
      subject.location = nil
      subject.loc_json.should be_a(String)
      subject.loc_json.should eq('')
    end

    it 'should accept a valid geojson string' do
      subject.location = nil
      subject.should_not be_valid
      subject.loc_json = '{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.14,52.27]}}'
      subject.should be_valid
      subject.location.x.should eql(0.14)
      subject.location.y.should eql(52.27)
    end

    it 'should ignore a bogus geojson string' do
      subject.loc_json = 'Garbage'
      subject.should be_valid
    end

    it 'should not be deleted' do
      subject.deleted_at.should be_nil
    end
  end

  describe 'location sizes' do
    let(:factory) { RGeo::Geos.factory(srid: 4326) }

    describe 'for a point' do
      subject { FactoryGirl.create(:issue, location: 'POINT(1 1)') }
      it 'should return a zero size for points' do
        subject.size.should eql(0.0)
      end

      it 'should return 0 for the size ratio' do
        geom = factory.parse_wkt('POLYGON((1 1, 1 3, 3 3, 3 1, 1 1))')
        subject.size_ratio(geom).should eql(0.0)
      end
    end

    describe 'for a polygon' do
      subject { FactoryGirl.create(:issue, location: 'POLYGON ((0.1 0.1, 0.1 0.2, 0.2 0.2, 0.2 0.1, 0.1 0.1))') }

      it 'should return the area for polygons' do
        subject.size.should be_within(0.0001).of(0.01)
      end

      it 'shoud give the correct size ratio' do
        geom = factory.parse_wkt('POLYGON((1 1, 1 3, 3 3, 3 1, 1 1))')
        subject.size_ratio(geom).should be_within(0.0001).of(0.0025)
      end

      it 'should cope with degenerate bboxes' do
        geom = factory.parse_wkt('POLYGON((1 1, 1 3, 1 3, 1 1, 1 1))')
        geom.area.should eql(0.0)
        subject.size_ratio(geom).should eql(0.0)
      end

      it 'should cope with non-polygon bboxes' do
        geom = factory.parse_wkt('POINT(1 1)')
        subject.size_ratio(geom).should eql(0.0)
      end
    end

    describe 'too large' do
      subject { FactoryGirl.create(:issue) }

      it 'should be invalid' do
        large_wkt = 'POLYGON((1 1, 1 3, 3 3, 3 1, 1 1))'
        geom = factory.parse_wkt(large_wkt)
        geom.area.should be >= Geo::ISSUE_MAX_AREA
        subject.location = large_wkt
        subject.should_not be_valid
        subject.should have(1).error_on(:size)
      end
    end
  end

  describe 'threads' do
    context 'new thread' do
      subject { FactoryGirl.create(:issue) }

      it 'should set the title to be the same as the issue' do
        thread = subject.threads.build
        thread.title.should == subject.title
      end

      it 'should set the privacy to public by default' do
        thread = subject.threads.build
        thread.should be_public
      end
    end
  end

  describe 'intersects' do
    context 'should accept a variety of geometry types' do
      subject { FactoryGirl.create(:issue) }
      let(:factory) { RGeo::Geos.factory(srid: 4326) }

      it 'should accept a point' do
        geom = factory.parse_wkt('POINT(-1 1)')
        lambda { Issue.intersects(geom).all }.should_not raise_error
      end

      it 'should accept a multipolygon' do
        geom2 = factory.parse_wkt('MULTIPOLYGON (((0.0 0.0, 0.0 1.0, 1.0 1.0, 0.0 0.0)), ((0.0 4.0, 0.0 5.0, 1.0 5.0, 0.0 4.0)))')
        lambda { Issue.intersects(geom2).all }.should_not raise_error
      end
    end

    context 'different issue locations' do
      let(:factory) { RGeo::Geos.factory(srid: 4326) }
      let(:polygon) { 'POLYGON ((0.1 0.1, 0.1 0.2, 0.2 0.2, 0.2 0.1, 0.1 0.1))' }
      let!(:issue_entirely_surrounding) { FactoryGirl.create(:issue, location: 'POLYGON ((0 0, 0 0.3, 0.3 0.3, 0.3 0, 0 0))') }
      let!(:issue_entirely_contained) { FactoryGirl.create(:issue, location: 'POLYGON ((0.12 0.12, 0.12 0.18, 0.18 0.18, 0.18 0.12, 0.12 0.12))') }
      let!(:issue_not_intersecting) { FactoryGirl.create(:issue, location: 'POLYGON ((1.1 1.1, 1.1 1.2, 1.2 1.2, 1.2 1.1, 1.1 1.1))' ) }
      let!(:issue_half_in_half_out) { FactoryGirl.create(:issue, location: 'POLYGON ((0 0.12, 0 0.18, 0.3 0.18, 0.3 0.12, 0 0.12))' ) }

      it 'should return intersecting issues' do
        bbox = factory.parse_wkt(polygon)
        issues = Issue.intersects(bbox).all
        issues.length.should eql(3)
        issues.should include(issue_entirely_surrounding)
        issues.should include(issue_entirely_contained)
        issues.should include(issue_half_in_half_out)
        issues.should_not include(issue_not_intersecting)
      end

      it 'should return intersecting but not covering issues' do
        bbox = factory.parse_wkt(polygon)
        issues = Issue.intersects_not_covered(bbox).all
        issues.length.should eql(2)
        issues.should include(issue_entirely_contained)
        issues.should include(issue_half_in_half_out)
        issues.should_not include(issue_entirely_surrounding)
        issues.should_not include(issue_not_intersecting)
      end
    end
  end

  describe 'find with index (search)' do
    subject { FactoryGirl.create(:issue) }

    it 'should return the issue on title search' do
      subject
      results = Issue.find_with_index(subject.title)
      results.should include(subject)
    end

    it 'should return the issue on a description search' do
      subject
      results = Issue.find_with_index(subject.description)
      results.should include(subject)
    end

    it 'should match partial searches' do
      subject
      results = Issue.find_with_index(subject.description.split[0])
      results.should include(subject)
      results = Issue.find_with_index(subject.description.split[-1])
      results.should include(subject)
    end

    it 'should not find gobbledy-gook' do
      subject
      results = Issue.find_with_index('asdfasdf12354')
      results.should be_empty
    end
  end

  describe 'destroyed' do
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

    it 'should appear when the default scope is removed' do
      Issue.unscoped.should include(subject)
    end
  end

  describe 'votes' do
    subject { FactoryGirl.create(:issue) }
    let(:brian) { FactoryGirl.create(:brian) }
    let(:meg) { FactoryGirl.create(:meg) }

    it 'should allow upvoting' do
      brian.vote_for(subject)
      subject.votes_count.should eql(1)
      subject.votes_for.should eql(1)
      subject.votes_against.should eql(0)
    end

    it 'should allow downvoting' do
      brian.vote_against(subject)
      subject.votes_against.should eql(1)
    end

    it 'should not allow duplicate votes' do
      brian.vote_for(subject)
      lambda { brian.vote_for(subject) }.should raise_error
    end

    it 'should allow a change of vote' do
      brian.vote_against(subject)
      brian.vote_exclusively_for(subject)
      subject.votes_count.should eql(1)
      subject.votes_for.should eql(1)
      subject.votes_against.should eql(0)
    end

    it 'should allow votes to be cleared' do
      brian.vote_for(subject)
      brian.clear_votes(subject)
      subject.votes_count.should eql(0)
      brian.voted_for?(subject).should be_false
    end

    it 'should give a plusminus summary' do
      brian.vote_for(subject)
      meg.vote_for(subject)
      subject.plusminus.should eql(2)
      meg.vote_exclusively_against(subject)
      subject.plusminus.should eql(0)
      brian.vote_exclusively_against(subject)
      subject.plusminus.should eql(-2)
    end
  end

  describe 'with a photo' do
    subject { FactoryGirl.create(:issue, :with_photo) }

    it 'should have a photo' do
      subject.photo.should be_true  # Hard to find a proper test
      subject.photo.mime_type.should == 'image/jpeg'
    end

    it 'should be stored in its own directory' do
      subject.photo_uid.should =~ /issue_photos/
    end
  end

  context 'finding from tags' do
    let(:tag) { FactoryGirl.create(:tag) }
    subject { FactoryGirl.create(:issue, tags: [tag]) }

    it 'should find the issue given a tag' do
      Issue.find_by_tag(tag).should include(subject)
    end

    it 'should find the issue given a taggable' do
      Issue.find_by_tags_from(double(tags: [tag])).should include(subject)
    end
  end

  context 'tags with icons' do
    subject { FactoryGirl.create(:issue) }
    let(:tag) { FactoryGirl.create(:tag) }
    let(:tag_with_icon) { FactoryGirl.create(:tag_with_icon) }
    let(:tag_with_icon2) { FactoryGirl.create(:tag_with_icon) }

    it 'should return an icon identifier' do
      subject.tags = [tag, tag_with_icon]
      subject.icon_from_tags.should eq(tag_with_icon.icon)
    end

    it 'should return no icon identifier' do
      subject.tags = [tag]
      subject.icon_from_tags.should be_nil
    end

    it 'should be consistent with respect to tag order' do
      subject.tags_string = "#{tag_with_icon.name} #{tag_with_icon2.name}"
      subject.icon_from_tags.should eq(tag_with_icon.icon)
      subject.tags_string = "#{tag_with_icon2.name} #{tag_with_icon.name}"
      subject.icon_from_tags.should eq(tag_with_icon.icon)
    end
  end

  context 'scopes' do
    describe 'by_most_recent' do
      it 'should set the order to be by created_at descending' do
        Issue.by_most_recent.orders.first.should == 'created_at DESC'
      end
    end

    describe 'created_by' do
      it 'should find issues created by the given user' do
        user = FactoryGirl.create(:user)
        owned_issues = FactoryGirl.create_list(:issue, 2, created_by: user)
        other_issue = FactoryGirl.create(:issue)
        Issue.count.should == 3
        Issue.created_by(user).should match_array(owned_issues)
      end
    end
  end
end
