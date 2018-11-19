require 'spec_helper'

describe Route::MessageApi do
  include Rack::Test::Methods

  def create_post
    post "api/membership", email: "test@example.com", api_key: api_key, full_name: "Full Name", group: group.short_name, role: role
  end

  describe 'POST' do
    let(:membership) { create(:group_membership, role: :committee) }
    let(:user) { membership.user}
    let(:api_key) { user.api_key }
    let(:role) { "member" }
    let(:group) { membership.group }

    context "when the create POST is valid" do
      it "creates a new user" do
        create_post
        expect(last_response.status).to eq(201)
        expect(json_response).to eq({ "status" => "success", "data" => nil })
      end
    end

    context "when the API key is for a non-committee member" do
      let(:api_key) { create(:group_membership).user.api_key }

      it "creates a new user" do
        create_post
        expect(json_response).to eq({"error" => "Not a committee member"})
      end
    end
  end
end
