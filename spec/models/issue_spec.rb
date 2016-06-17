require 'spec_helper'

describe Issue do
  it_should_behave_like 'a taggable model'

  describe 'validates' do
    %w(www.example.com http://www.example.com).each do |url|
      it "should accept valid urls such as #{url}"  do
        subject.external_url = url
        expect(subject).to have(:no).error_on(:external_url)
      end
    end

    it "should not accept invalid urls" do
      subject.external_url = 'w[iki]pedia.org/wiki/Family_Guy'
      expect(subject).to have(1).error_on(:external_url)
    end
  end

  it { is_expected.to validate_length_of(:title).is_at_most(254) }

  describe 'newly created' do
    subject { create(:issue) }

    it 'must have a created_by user' do
      expect(subject.created_by).to be_valid
    end

    it 'should have an centre x' do
      expect(subject.centre.x).to be_a(Float)
    end

    it 'should have longitudes for x' do
      expect(subject.centre.x).to be < 181
      expect(subject.centre.x).to be > -181
    end

    it 'should have latitudes for y' do
      expect(subject.centre.y).to be < 90
      expect(subject.centre.y).to be > -90
    end

    it 'should have a geojson string' do
      expect(subject.loc_json).to be_a(String)
      expect(subject.loc_json).to eql(RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(subject.location)).to_json)
    end

    it 'should have a geojson feature representation' do
      expect(subject.loc_feature).to be_a(RGeo::GeoJSON::Feature)
      expect(subject.loc_feature).to eql(RGeo::GeoJSON::Feature.new(subject.location))
      expect(subject.loc_feature.geometry).not_to be_nil
    end

    it 'should accept properties for feature' do
      f = subject.loc_feature(foo: 'bar')
      expect(f.properties).not_to be_nil
      expect(f.property(:foo)).to eql('bar')
    end

    it 'should have no votes' do
      expect(subject.votes_count).to be(0)
    end

    it 'works when creator is deleted' do
      subject.created_by.destroy
      expect(subject.reload.created_by).to_not be_nil
    end
  end

  describe 'to be valid' do
    subject { create(:issue) }

    it 'must have a title' do
      subject.title = ''
      expect(subject).not_to be_valid
    end

    it 'must have a created_by user' do
      subject.created_by = nil
      expect(subject).not_to be_valid
    end

    it 'must have a description' do
      subject.description = nil
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

    it 'should not be deleted' do
      expect(subject.deleted_at).to be_nil
    end
  end

  describe 'location sizes' do
    let(:factory) { RGeo::Geos.factory(srid: 4326) }

    describe 'for a point' do
      subject { create(:issue, location: 'POINT(1 1)') }
      it 'should return a zero size for points' do
        expect(subject.size).to eql(0.0)
      end

      it 'should return 0 for the size ratio' do
        geom = factory.parse_wkt('POLYGON((1 1, 1 3, 3 3, 3 1, 1 1))')
        expect(subject.size_ratio(geom)).to eql(0.0)
      end
    end

    describe 'for a polygon' do
      subject { create(:issue, location: 'POLYGON ((0.1 0.1, 0.1 0.2, 0.2 0.2, 0.2 0.1, 0.1 0.1))') }

      it 'should return the area for polygons' do
        expect(subject.size).to be_within(0.0001).of(0.01)
      end

      it 'shoud give the correct size ratio' do
        geom = factory.parse_wkt('POLYGON((1 1, 1 3, 3 3, 3 1, 1 1))')
        expect(subject.size_ratio(geom)).to be_within(0.0001).of(0.0025)
      end

      it 'should cope with degenerate bboxes' do
        geom = factory.parse_wkt('POLYGON((1 1, 1 3, 1 3, 1 1, 1 1))')
        expect(geom.area).to eql(0.0)
        expect(subject.size_ratio(geom)).to eql(0.0)
      end

      it 'should cope with non-polygon bboxes' do
        geom = factory.parse_wkt('POINT(1 1)')
        expect(subject.size_ratio(geom)).to eql(0.0)
      end
    end

    describe 'too large' do
      subject { create(:issue) }

      it 'should be invalid' do
        large_wkt = 'POLYGON((1 1, 1 3, 3 3, 3 1, 1 1))'
        geom = factory.parse_wkt(large_wkt)
        expect(geom.area).to be >= Geo::ISSUE_MAX_AREA
        subject.location = large_wkt
        expect(subject).not_to be_valid
        expect(subject).to have(1).error_on(:size)
      end
    end
  end

  describe 'threads' do
    context 'new thread' do
      subject { create(:issue) }

      it 'should set the title to be the same as the issue' do
        thread = subject.threads.build
        expect(thread.title).to eq(subject.title)
      end

      it 'should set the privacy to public by default' do
        thread = subject.threads.build
        expect(thread).to be_public
      end
    end
  end

  describe 'intersects' do
    context 'should accept a variety of geometry types' do
      subject { create(:issue) }
      let(:factory) { RGeo::Geos.factory(srid: 4326) }

      it 'should accept a point' do
        geom = factory.parse_wkt('POINT(-1 1)')
        expect { Issue.intersects(geom).to_a }.not_to raise_error
      end

      it 'should accept a multipolygon' do
        geom2 = factory.parse_wkt('MULTIPOLYGON (((0.0 0.0, 0.0 1.0, 1.0 1.0, 0.0 0.0)), ((0.0 4.0, 0.0 5.0, 1.0 5.0, 0.0 4.0)))')
        expect { Issue.intersects(geom2).to_a }.not_to raise_error
      end
    end

    context 'different issue locations' do
      let(:factory) { RGeo::Geos.factory(srid: 4326) }
      let(:polygon) { 'POLYGON ((0.1 0.1, 0.1 0.2, 0.2 0.2, 0.2 0.1, 0.1 0.1))' }
      let!(:issue_entirely_surrounding) { create(:issue, location: 'POLYGON ((0 0, 0 0.3, 0.3 0.3, 0.3 0, 0 0))') }
      let!(:issue_entirely_contained) { create(:issue, location: 'POLYGON ((0.12 0.12, 0.12 0.18, 0.18 0.18, 0.18 0.12, 0.12 0.12))') }
      let!(:issue_not_intersecting) { create(:issue, location: 'POLYGON ((1.1 1.1, 1.1 1.2, 1.2 1.2, 1.2 1.1, 1.1 1.1))') }
      let!(:issue_half_in_half_out) { create(:issue, location: 'POLYGON ((0 0.12, 0 0.18, 0.3 0.18, 0.3 0.12, 0 0.12))') }

      it 'should return intersecting issues' do
        bbox = factory.parse_wkt(polygon)
        issues = Issue.intersects(bbox).to_a
        expect(issues.length).to eql(3)
        expect(issues).to include(issue_entirely_surrounding)
        expect(issues).to include(issue_entirely_contained)
        expect(issues).to include(issue_half_in_half_out)
        expect(issues).not_to include(issue_not_intersecting)
      end

      it 'should return intersecting but not covering issues' do
        bbox = factory.parse_wkt(polygon)
        issues = Issue.intersects_not_covered(bbox).to_a
        expect(issues.length).to eql(2)
        expect(issues).to include(issue_entirely_contained)
        expect(issues).to include(issue_half_in_half_out)
        expect(issues).not_to include(issue_entirely_surrounding)
        expect(issues).not_to include(issue_not_intersecting)
      end
    end
  end

  describe 'destroyed' do
    subject { create(:issue) }

    before do
      subject.destroy
    end

    it "shouldn't really destroy" do
      expect(subject).to be_valid
      expect(subject.deleted_at).not_to be_nil
    end

    it "shouldn't appear on a normal find" do
      expect(Issue.all).not_to include(subject)
    end

    it 'should appear when the default scope is removed' do
      expect(Issue.unscoped).to include(subject)
    end
  end

  describe 'votes' do
    subject { create(:issue) }
    let(:brian) { create(:brian) }
    let(:meg) { create(:meg) }

    it 'should allow upvoting' do
      brian.vote_for(subject)
      expect(subject.votes_count).to eql(1)
      expect(subject.votes_for).to eql(1)
      expect(subject.votes_against).to eql(0)
    end

    it 'should allow downvoting' do
      brian.vote_against(subject)
      expect(subject.votes_against).to eql(1)
    end

    it 'should not allow duplicate votes' do
      brian.vote_for(subject)
      expect { brian.vote_for(subject) }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'should allow a change of vote' do
      brian.vote_against(subject)
      brian.vote_exclusively_for(subject)
      expect(subject.votes_count).to eql(1)
      expect(subject.votes_for).to eql(1)
      expect(subject.votes_against).to eql(0)
    end

    it 'should allow votes to be cleared' do
      brian.vote_for(subject)
      brian.clear_votes(subject)
      expect(subject.votes_count).to eql(0)
      expect(brian.voted_for?(subject)).to be_falsey
    end

    it 'should give a plusminus summary' do
      brian.vote_for(subject)
      meg.vote_for(subject)
      expect(subject.plusminus).to eql(2)
      meg.vote_exclusively_against(subject)
      expect(subject.plusminus).to eql(0)
      brian.vote_exclusively_against(subject)
      expect(subject.plusminus).to eql(-2)
    end
  end

  describe 'with a photo' do
    subject { create(:issue, :with_photo) }

    it 'should have a photo' do
      expect(subject.photo).to be_truthy  # Hard to find a proper test
      expect(subject.photo.format).to eq('jpeg')
    end

    it 'should be stored in its own directory' do
      expect(subject.photo_uid).to match(/issue_photos/)
    end
  end

  context 'finding from tags' do
    let(:tag) { create(:tag) }
    subject { create(:issue, tags: [tag]) }

    it 'should find the issue given a tag' do
      expect(Issue.find_by_tag(tag)).to include(subject)
    end

    it 'should find the issue given a taggable' do
      expect(Issue.find_by_tags_from(double(tags: [tag]))).to include(subject)
    end
  end

  context 'tags with icons' do
    subject { create(:issue) }
    let(:tag) { create(:tag) }
    let(:tag_with_icon) { create(:tag_with_icon) }
    let(:tag_with_icon2) { create(:tag_with_icon) }

    it 'should return an icon identifier' do
      subject.tags = [tag, tag_with_icon]
      expect(subject.icon_from_tags).to eq(tag_with_icon.icon)
    end

    it 'should return no icon identifier' do
      subject.tags = [tag]
      expect(subject.icon_from_tags).to be_nil
    end

    it 'should be consistent with respect to tag order' do
      subject.tags_string = "#{tag_with_icon.name} #{tag_with_icon2.name}"
      expect(subject.icon_from_tags).to eq(tag_with_icon.icon)
      subject.tags_string = "#{tag_with_icon2.name} #{tag_with_icon.name}"
      expect(subject.icon_from_tags).to eq(tag_with_icon.icon)
    end
  end

  context 'scopes' do
    describe 'by_most_recent' do
      it 'should set the order to be by created_at descending' do
        expect(Issue.by_most_recent.orders.first).to eq('created_at DESC')
      end
    end

    describe 'created_by' do
      it 'should find issues created by the given user' do
        user = create(:user)
        owned_issues = create_list(:issue, 2, created_by: user)
        create(:issue)
        expect(Issue.count).to eq(3)
        expect(Issue.created_by(user)).to match_array(owned_issues)
      end
    end

    describe 'dates scope' do
      let!(:one_day_old) { create :issue, created_at: 1.day.ago }
      let!(:two_day_old) { create :issue, deadline: 2.days.ago }
      let!(:four_day_old) { create :issue, deadline: 4.days.ago, created_at: 1.days.ago }

      it 'has before date scope' do
        expect(described_class.before_date(3.days.ago.to_date)).
          to match_array([four_day_old])
      end

      it 'has after date scope' do
        expect(described_class.after_date(3.days.ago.to_date)).
          to match_array([one_day_old, two_day_old])
      end
    end

    describe 'where_tag_names' do
      let(:tag1) { create :tag, name: 'tag1' }
      let(:tag2) { create :tag, name: 'tag2' }
      let(:tag3) { create :tag, name: 'tag3' }
      let!(:with_1_2) { create :issue, tags: [tag1, tag2] }
      let!(:with_1_3) { create :issue, tags: [tag1, tag3] }
      let!(:with_3) { create :issue, tags: [tag3] }

      it 'not in should return the issues which do not have any of the tags' do
        no_tag = create :issue

        expect(described_class.all.where_tag_names_not_in([])).to match_array([no_tag, with_1_2, with_1_3, with_3])
        expect(described_class.all.where_tag_names_not_in(['tag2'])).to match_array([no_tag, with_1_3, with_3])
        expect(described_class.all.where_tag_names_not_in(['tag1', 'tag2'])).to match_array([no_tag, with_3])
      end

      it 'in should return the issues which have all of the tags' do
        create :issue

        expect(described_class.where_tag_names_in(['tag1'])).to match_array([with_1_2, with_1_3])
        expect(described_class.where_tag_names_in(['tag1', 'tag2'])).to match_array([with_1_2])
        expect(described_class.where_tag_names_in([])).to match_array([])
      end
    end
  end

  it 'should have latest_activity_at' do
    subject = create :issue
    expect(subject.latest_activity_at).to eq nil
    thread = create :message_thread_with_messages, issue: subject
    expect(subject.latest_activity_at).to eq thread.messages.last.updated_at
    message = create :message, thread: thread, updated_at: Date.tomorrow
    expect(subject.latest_activity_at).to eq message.updated_at
  end

  it 'should email about deadlines' do
    issue = create :issue, deadline: 6.hours.from_now
    thread = create :message_thread, issue: issue
    subscription = create :thread_subscription, thread: thread
    user = subscription.user
    user.prefs.update_column(:email_status_id, 1)

    expect{described_class.email_upcomming_deadlines!}.to change{ all_emails.count }.by(1)
    email = all_emails.last
    expect(email.to).to include(user.email)
    expect(email.body).to include("upcoming deadline")
    expect(email.subject).to include("Upcoming deadline")
  end

  it 'should have closed?' do
    subject = create :issue
    expect(subject.closed?).to eq false
    thread = create :message_thread, issue: subject, closed: false
    expect(subject.reload.closed?).to eq false
    thread.update(closed: true)
    expect(subject.reload.closed?).to eq true
  end
end
