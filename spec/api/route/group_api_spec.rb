describe Route::GroupApi do
  include Rack::Test::Methods

  let(:geojson_response) { RGeo::GeoJSON.decode(last_response.body, json_parser: :json) }

  describe 'GET /' do
    let(:response_keys) { %w(description email size_ratio title url website) }
    let!(:small) { create :small_group_profile }

    before do
      create :big_group_profile
    end

    context 'for local and national groups' do
      before do
        get "/api/groups", national: 1
      end

      it 'returns issue' do
        expect(geojson_response.size).to eq(2)
        expect(last_response.status).to eq(200)
        expect(geojson_response[0].keys).to match_array(response_keys)
      end
    end

    context 'for local groups only' do
      before do
        get "http://cam.example.org/api/groups"
      end

      it 'returns issue' do
        expect(geojson_response.size).to eq(1)
        expect(last_response.status).to eq(200)
        expect(geojson_response[0].keys).to match_array(response_keys)
        expect(geojson_response[0]["url"]).to eq("http://#{small.group.short_name}.example.org")
      end
    end
  end
end
