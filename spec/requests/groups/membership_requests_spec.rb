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

      it "should not html escape the name of the group" do
        current_group.name = "A & B"
        current_group.save
        visit group_membership_requests_path(gmr.group)
        click_on "Confirm"
        open_email(gmr.user.email)
        current_email.should have_body_text("A & B")
      end

      it "should let you view the user profile" do
        visit group_membership_requests_path(gmr.group)
        click_on gmr.user.name
        page.should have_content(gmr.user.name)
        current_path.should eql(user_profile_path(gmr.user))
      end
    end

    describe "when being inviting a new member" do
      before do
        visit new_group_membership_path(group_id: current_group)
        @credentials = FactoryGirl.attributes_for(:user)
        fill_in "Full name", with: @credentials[:full_name]
        fill_in "Email", with: @credentials[:email]
        click_on "Invite member"
        click_on "Sign out"
      end

      it "should let you complete the invitation by filling in just the password and confirmation" do
        user = User.find_by_email(@credentials[:email])
        visit accept_user_invitation_path(invitation_token: user.invitation_token)
        fill_in "New Password", with: "Password1"
        fill_in "New Password Confirmation", with: "Password1"
        click_button "Confirm account"
        page.should have_content("Your password was set successfully. You are now signed in.")
      end
      
      it "should let you complete the invitation and change name and email" do
        user = User.find_by_email(@credentials[:email])
        visit accept_user_invitation_path(invitation_token: user.invitation_token)
        fill_in "Full name", with: "Shaun McDonald"
        fill_in "Display name", with: "smsm1"
        fill_in "Email", with: "some_other_email@example.com"
        fill_in "New Password", with: "Password1"
        fill_in "New Password Confirmation", with: "Password1"
        click_button "Confirm account"
        page.should have_content("Your password was set successfully. You are now signed in.")
        User.find_by_email(@credentials[:email]).should be_nil
        updated_user = User.find_by_email("some_other_email@example.com")
        updated_user.full_name.should eq "Shaun McDonald"
        updated_user.display_name.should eq "smsm1"
      end
    end
    
  end

  context "as the original user" do
    include_context "signed in as a site user"
    let(:group) { FactoryGirl.create(:group) }

    before do
      visit group_path(group)
      click_link I18n.t(".groups.show.join_this_group")
      click_button "Create Group membership request"
    end

    describe "cancelling the request" do
      it "should cancel the request"
    end

    describe "signing up again" do
      it "should not show a link on the page" do
        visit group_path(group)
        page.should_not have_content(I18n.t(".groups.join_this_group"))
        page.should have_content(I18n.t(".groups.show.group_request_pending"))
      end

      it "should not let you go directly" do
        visit new_group_membership_request_path(group)
        click_button "Create Group membership request"
        page.should have_content(I18n.t(".group.membership_requests.create.already_asked"))
      end
    end
  end

  context "as a different user" do
    describe "cancelling the request" do
      it "should not cancel the request"
    end
  end
end
