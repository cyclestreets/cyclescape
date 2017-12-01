require 'spec_helper'

describe Route::ThreadApi do
  include Rack::Test::Methods

  describe 'GET /' do
    let(:response_keys) do
      [
        "closed", "created_at", "created_by_id", "created_by_name",
        "deleted_at", "group_id", "id", "issue_id", "privacy", "status", "updated_at"
      ]
    end
    let!(:resource) { create :message_thread }

    before do
      get "/api/threads"
    end

    it "returns threads" do
      expect(json_response.size).to eq(1)
      expect(last_response.status).to eq(200)
      expect(json_response[0].keys).to match_array(response_keys)
    end
  end
end
