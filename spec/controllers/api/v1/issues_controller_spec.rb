require 'spec_helper'

RSpec.describe Api::V1::IssuesController, type: :controller do
  describe 'routing' do
    it { is_expected.to route(:get, '/api/v1/issues').to(action: :index, format: :json) }
  end

  describe 'GET index.json' do
    context 'with full request' do
      before do
        tag = create :tag, name: 'taga'
        create :issue_within_quahog, tags: [tag] # location 0.11906 52.20792
        get :index, bbox: '0.11905,52.20791,0.11907,52.20793', tags: ['taga'], format: :json
      end

      it 'returns issue' do
        expect(JSON.load(response.body).size).to eq(1)
      end

      it 'has the correct fields' do
        expect(JSON.load(response.body)[0].keys).to match_array(%w(id created_at created_by description tags location cyclescape_url))
      end
    end
  end
end
