require 'spec_helper'

RSpec.describe Api::V1::IssuesController, type: :controller do
  describe 'routing' do
    it { is_expected.to route(:get, '/api/v1/issues').to(action: :index, format: :json) }
  end

  let(:geojson_response) { RGeo::GeoJSON.decode(response.body, json_parser: :json) }

  describe 'GET index.json' do
    context 'with bounding box' do
      before do
        tag = create :tag, name: 'taga'
        create :issue_within_quahog, tags: [tag] # location 0.11906 52.20792
        get :index, bbox: '0.11905,52.20791,0.11907,52.20793', tags: ['taga'], format: :json
      end

      it 'returns issue' do
        expect(geojson_response.size).to eq(1)
      end

      it 'has the correct fields' do
        expect(geojson_response[0].keys).
          to match_array(%w(id created_at created_by deadline external_url
                            description tags cyclescape_url))
      end
    end

    context 'with dates' do
      before do
        create :issue, deadline: 1.day.ago, id: 42
        create :issue, created_at: 3.days.ago, deadline: 3.day.ago
      end

      it 'respects the start date parameter' do
        get :index, start_date: 2.days.ago, format: :json

        expect(geojson_response.size).to eq(1)
        expect(geojson_response[0]['id']).to eq(42)
      end

      it 'respects the end date parameter' do
        get :index, end_date: 2.days.ago, format: :json

        expect(geojson_response.size).to eq(1)
        expect(geojson_response[0]['id']).to_not eq(42)
      end
    end

    context 'with per page' do
      before do
        3.times { create :issue }

        get :index, per_page: 2, format: :json
      end

      it 'respects the per_page parameters' do
        expect(JSON.load(response.body).size).to eq(2)
      end
    end
  end
end
