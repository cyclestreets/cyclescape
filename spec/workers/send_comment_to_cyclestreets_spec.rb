# frozen_string_literal: true

require "spec_helper"

describe SendCommentToCyclestreets do
  before do
    stub_const("Geocoder::API_KEY", api_key)
  end

  let(:comment) { create(:site_comment) }

  before do
    stub_request(:post, Geocoder::FEEDBACK_URL).with(
      body: comment.cyclestreets_body,
      headers: {
        "X-Api-Key" => api_key,
        "Content-Type" => Mime[:url_encoded_form].to_s,
        "Host" => "api.cyclestreets.net:443"
      }
    ).to_return(body: { id: 1 }.to_json)
  end

  context "with API key" do
    let(:api_key) { "key" }

    it "sends to cyclestreets" do
      expect { described_class.perform(comment.id) }.to change { comment.reload.sent_to_cyclestreets_at }.from(nil)
      expect(comment.cyclestreets_response).to eq("id" => 1)
    end
  end

  context "without API key" do
    let(:api_key) { "" }

    it "does not send to cyclestreets" do
      expect { described_class.perform(comment.id) }.not_to change(comment.reload, :sent_to_cyclestreets_at)
    end
  end
end
