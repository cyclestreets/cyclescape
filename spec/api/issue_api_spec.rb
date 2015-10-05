require 'spec_helper'

describe IssueApi::API do
  include Rack::Test::Methods

  let(:geojson_response) { RGeo::GeoJSON.decode(last_response.body, json_parser: :json) }

  describe "GET /issue" do
    it "returns 200" do
      get "/api/issues"
      expect(last_response.status).to eq(200)
    end
  end

  describe 'GET index.json' do
    context 'with bounding box' do
      let(:host) { "" }
      before do
        tag = create :tag, name: 'taga'
        create :issue_within_quahog, tags: [tag] # location 0.11906 52.20792
        get "#{host}/api/issues", bbox: '0.11905,52.20791,0.11907,52.20793', tags: ["taga"]
      end

      it 'returns issue' do
        expect(geojson_response.size).to eq(1)
      end

      it 'has the correct fields' do
        expect(geojson_response[0].keys).
          to match_array(%w(id created_at created_by deadline external_url
                            description tags cyclescape_url))
      end
      context 'with a subdomain' do
        let(:host) { 'http://cam.example.com' }

        it 'returns cyclescape url with subdomain' do
          expect(geojson_response[0]['cyclescape_url']).to match(/cam\.example\.com\/issues/)
        end
      end
    end

    context 'with dates' do
      before do
        create :issue, deadline: 1.day.ago, id: 42
        create :issue, created_at: 3.days.ago, deadline: 3.day.ago
      end

      it 'respects the start date parameter' do
        get "api/issues", start_date: 2.days.ago.strftime("%Y/%m/%d")

        expect(geojson_response.size).to eq(1)
        expect(geojson_response[0]['id']).to eq(42)
      end

      it 'respects the end date parameter' do
        get "api/issues", end_date: 2.days.ago.strftime("%Y/%m/%d")

        expect(geojson_response.size).to eq(1)
        expect(geojson_response[0]['id']).to_not eq(42)
      end
    end

    context 'with per page' do
      before do
        3.times { create :issue }

        get "api/issues", per_page: 2
      end

      it 'respects the per_page parameters' do
        expect(geojson_response.size).to eq(2)
      end
    end
  end
end
