require 'rails_helper'

RSpec.describe "GroupRequests", :type => :request do
  describe "GET /group_requests" do
    it "works! (now write some real specs)" do
      get group_requests_path
      expect(response).to have_http_status(200)
    end
  end
end
