# frozen_string_literal: true

require "spec_helper"

describe Route::ThreadApi do
  include Rack::Test::Methods

  describe "GET /" do
    let(:response_keys) do
      %w[
        closed created_at created_by_id created_by_name
        group_id id issue_id updated_at public_token title
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

    context "specifiying a group" do
      let(:group) { create :group }
      let!(:thread_in_group) { create :message_thread, group: group }

      it "return only threads for that group" do
        get "/api/threads", group: group.short_name

        expect(json_response.size).to eq(1)
        expect(json_response[0]["id"]).to eq(thread_in_group.id)
      end
    end
  end
end
