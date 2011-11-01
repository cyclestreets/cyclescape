require 'spec_helper'

describe "Group Membership Requests" do
  let(:request) { FactoryGirl.create(:meg_joining_quahogcc) }

  # The first one fails, but the others pass. Hmmm.
  context "as a group member" do
    include_context "signed in as a group member"

      before do
        visit group_membership_requests_path(request.group)
      end

    describe "viewing the requests" do
      it "should refuse" do
        visit group_membership_requests_path(request.group)
        page.should have_content("You are not authorised to access that page.")
      end
    end
  end

  # This fails, and I don't understand why. If you actually try it yourself, it works.
  context "as a committee member" do
    include_context "signed in as a committee member"

    before do
      visit group_membership_requests_path(request.group)
    end

    describe "confirming a request" do
      it "should send a notification" do
        click_on "Confirm"
        open_email(request.user.email)
        current_email.should have_subject("You are now a member of #{request.group.name}")
      end
    end
  end

  context "as the original user" do
    describe "cancelling the request" do
      it "should cancel the request"
    end

    describe "signing up again" do
      it "should not let you"
    end
  end

  context "as a different user" do
    describe "cancelling the request" do
      it "should not cancel the request"
    end
  end
end
