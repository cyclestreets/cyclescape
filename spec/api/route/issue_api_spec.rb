# frozen_string_literal: true

require "spec_helper"

describe Route::IssueApi do
  include Rack::Test::Methods

  let(:geojson_response) { RGeo::GeoJSON.decode(last_response.body) }

  describe "GET /" do
    context "pagination" do
      before { create_list :issue, 201, created_by: create(:user) }

      it "has default pagination" do
        get "api/issues"
        expect(geojson_response.size).to eq(200)
      end

      it "respects pagination" do
        get "api/issues", page: 3, per_page: 100
        expect(geojson_response.size).to eq(1)
      end
    end

    context "with a geo_collection" do
      let!(:issue) { create :issue_within_quahog }
      let(:locables) { [build_stubbed(:quahogcc_group_profile), build_stubbed(:small_group_profile)] }
      let(:host) { "" }

      before do
        create :issue
        get "#{host}/api/issues", geo_collection: geo_collection
      end

      context "with geometries" do
        let(:geo_features) { locables.map { |loc| RGeo::GeoJSON::Feature.new(loc.location) } }
        let(:geo_collection) { RGeo::GeoJSON.encode(RGeo::GeoJSON::FeatureCollection.new(geo_features)).to_json }

        it "returns issue" do
          expect(geojson_response.size).to eq(1)
          expect(geojson_response[0]["id"]).to eq(issue.id)
          expect(last_response.status).to eq(200)
        end
      end

      context "with an invalid geometry" do # e.g. the Polygon has self-interestion
        let(:geo_collection) do
          <<-GEO
          {"type":"FeatureCollection",
           "features":[
             {"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-0.15071868896484375,51.652323870435474],[-0.1535377502441667,51.647943918259216],[-0.16642570495605466,51.63016558661912],[-0.16761398315432496,51.611607930855016],[-0.1970672607421875,51.5922157026931],[-0.20333290100097656,51.59088261613596],[-0.20685195922851562,51.59056266954099],[-0.2187824249267578,51.579576469589995],[-0.23989677429199216,51.57872306133139],[-0.23903846740722656,51.585389886893026],[-0.23569107055664062,51.5921090572082],[-0.2362060546875,51.605651030611924],[-0.2077960968017578,51.61172761133676],[-0.20161628723144528,51.60895593856035],[-0.1929473876953125,51.614445818337245],[-0.18342018127441403,51.630911474166794],[-0.20977020263671875,51.64177872993458],[-0.2006721496582031,51.64721138136228],[-0.20376205444335935,51.64923514389964],[-0.2410125732421875,51.679580741628975],[-0.2767181396484375,51.71639405046408],[-0.35430908203125,51.71724487103152],[-0.37078857421875,51.736384102036176],[-0.358428955078125,51.754240074033525],[-0.317230224609375,51.767839887322154],[-0.33096313476562494,51.81837825714121],[-0.248565673828125,51.87733877579231],[-0.218353271484375,51.84595933666335],[-0.2032470703125,51.791629704426924],[-0.19775390625,51.82050047836314],[-0.208740234375,51.85783521205157],[-0.20050048828125,51.798424491278745],[-0.22659301757812497,51.90869633027845],[-0.208740234375,51.84765608216451],[-0.23345947265625,51.90446010157102],[-0.190887451171875,51.831534417403034],[-0.22796630859374997,51.90446010157102],[-0.19500732421874997,51.876490970614775],[-0.17990112304687497,51.89090148463458],[-0.199127197265625,51.89344403698398],[-0.166168212890625,51.84002022371389],[-0.22521972656249997,51.851049381288874],[-0.1593017578125,51.779736363786355],[-0.199127197265625,51.86292391360244],[-0.1682281494140625,51.892596535517995],[-0.1702880859375,51.85529064543267],[-0.168914794921875,51.82813964710642],[-0.22521972656249997,51.82389582440221],[-0.1922607421875,51.82389582440221],[-0.11398315429687499,51.76996448812036],[-0.10711669921875,51.66627377119407],[-0.15071868896484375,51.652323870435474]]]},"properties":{"thumbnail":null,"anchor":null}},
             {"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-0.2244484235794024,51.76748],[-0.22530623834420271,51.76911379685293],[-0.22755202655450155,51.770123509271215],[-0.23032797344549844,51.770123509271215],[-0.23257376165579727,51.76911379685293],[-0.2334315764205976,51.76748],[-0.23257376165579727,51.76584614401134],[-0.23032797344549844,51.76483633590937],[-0.22755202655450155,51.76483633590937],[-0.22530623834420271,51.76584614401134],[-0.2244484235794024,51.76748]]]},"properties":{"thumbnail":null,"anchor":null}}
           ]
          }
          GEO
        end

        it "returns issue" do
          expect(last_response.status).to eq(200)
        end
      end
    end

    context "with bounding box" do
      let(:host) { "" }
      before do
        tag = create :tag, name: "taga"
        create :issue_within_quahog, tags: [tag] # location 0.11906 52.20792
        create :issue, tags: [tag]
        create :issue
        get "#{host}/api/issues", bbox: "0.11905,52.20791,0.11907,52.20793", tags: ["taga"].to_json
      end

      it "returns issue" do
        expect(geojson_response.size).to eq(1)
        expect(last_response.status).to eq(200)
      end

      it "has the correct fields" do
        expect(geojson_response[0].keys)
          .to match_array(%w[id created_at created_at_iso created_by deadline deadline_iso external_url description
                             tags cyclescape_url photo_thumb_url thumbnail title vote_count
                             latest_activity_at latest_activity_at_iso closed])
      end

      context "with a subdomain" do
        let(:host) { "http://cam.example.com" }

        it "returns cyclescape url with subdomain" do
          expect(geojson_response[0]["cyclescape_url"]).to match(%r{cam\.example\.com/issues})
        end
      end
    end

    context "with dates" do
      before do
        create :issue, deadline: 1.day.ago, id: 4242
        create :issue, created_at: 3.days.ago, deadline: 3.days.ago
      end

      it "respects the start date parameter" do
        get "api/issues", start_date: 2.days.ago.strftime("%Y/%m/%d")

        expect(geojson_response.size).to eq(1)
        expect(geojson_response[0]["id"]).to eq(4242)
      end

      it "respects the end date parameter" do
        get "api/issues", end_date: 2.days.ago.strftime("%Y/%m/%d")

        expect(geojson_response.size).to eq(1)
        expect(geojson_response[0]["id"]).to_not eq(4242)
      end
    end

    context "with group" do
      let!(:group_profile) { create(:quahogcc_group_profile) }
      let!(:inside_group)  { create :issue_within_quahog }
      let!(:outside_group) { create :issue }

      before do
        get "api/issues", group: group_profile.reload.group.short_name
      end

      it "should only return issues inside the groups area" do
        expect(last_response.inspect).to include(inside_group.to_param)
        expect(geojson_response.size).to eq(1)
        expect(geojson_response[0]["id"]).to eq(inside_group.id)
      end
    end

    context "should hide issues creators if hidden" do
      let(:user)   { create :user }
      let!(:issue) { create :issue, created_by: user }

      before do
        create :user_profile, user: user, visibility: "group"
        get "api/issues"
      end

      it "should hide the users name" do
        expect(geojson_response[0]["created_by"]).to eq("Anon")
      end
    end
  end
end
