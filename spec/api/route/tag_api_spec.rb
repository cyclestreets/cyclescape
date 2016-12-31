require 'spec_helper'

describe Route::TagApi do
  include Rack::Test::Methods
  let(:json_response) { JSON.parse(last_response.body) }

  describe 'GET /' do
    let(:response_keys) { %w(icon id name tag_count url) }
    let!(:resource) { create :tag }

    before do
      get "/api/tags"
    end

    it "returns tags" do
      expect(json_response.size).to eq(1)
      expect(last_response.status).to eq(200)
      expect(json_response[0].keys).to match_array(response_keys)
    end
  end
end
