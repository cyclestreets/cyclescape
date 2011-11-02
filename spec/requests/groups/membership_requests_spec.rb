require 'spec_helper'

describe "Group Membership Requests" do
  let(:meg) { FactoryGirl.create(:meg) }

  context "as a group member" do
    include_context "signed in as a group member"
    let(:gmr) { GroupMembershipRequest.create({group: current_group, user: meg}) }

    describe "viewing the requests" do
      it "should refuse" do
        visit group_membership_requests_path(gmr.group)
        page.should have_content("You are not authorised to access that page.")
      end
    end
  end

  context "as a committee member" do
    include_context "signed in as a committee member"
    let(:gmr) { GroupMembershipRequest.create({group: current_group, user: meg}) }

    describe "confirming a request" do
      it "should send a notification" do
        visit group_membership_requests_path(gmr.group)
        click_on "Confirm"
        open_email(gmr.user.email)
        current_email.should have_subject("You are now a member of #{gmr.group.name}")
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
