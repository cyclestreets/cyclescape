require 'spec_helper'

describe Route::ConstituencyApi do
  include Rack::Test::Methods
  let(:geojson_response) { RGeo::GeoJSON.decode(last_response.body, json_parser: :json) }

  describe 'GET /' do
    let(:response_keys) { %w(name) }
    let!(:resource) { create :constituency }

    before do
      get "/api/constituencies", geo: RGeo::GeoJSON.encode((build :issue_within_quahog).location).to_json
    end

    it "returns a constituency" do
      expect(last_response.status).to eq(200)
      expect(geojson_response[0].keys).to match_array(response_keys)
    end
  end
end
