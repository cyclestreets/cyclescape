require 'spec_helper'

describe "Group Membership Requests" do
  let(:request) { FactoryGirl.create(:pending_gmr) }

  context "confirm a request" do
    include_context "signed in as a site user"

    before do
      visit group_membership_requests_path(request.group)
    end

    describe "it should send a notification" do
      it "should send a notification confirming the request" do
        click_on "Confirm"
        open_email(request.user.email)
        current_email.should have_subject("You are now a member of #{request.group.name}")
      end
    end
  end
end