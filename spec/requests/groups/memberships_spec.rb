require 'spec_helper'

describe "Group memberships admin" do
  include_context "signed in as admin"

  before do
    @group = FactoryGirl.create(:group)
  end

  context "new" do
    before do
      visit new_group_membership_path(@group)
    end

    it "should show the new member form" do
      page.should have_field("Full name")
      page.should have_field("Email")
    end
  end

  context "create" do
    before do
      visit new_group_membership_path(@group)
    end

    it "should create a new group member and send an invitation email" do
      select "Member", from: "Membership type"
      fill_in "Full name", with: "Brian Griffin"
      fill_in "Email", with: "briang@example.com"
      click_button "Invite member"
      User.find_by_email("briang@example.com").should be_true
      email = open_email "briang@example.com"
      email.subject.should =~ /Invitation/
    end

    it "should display an error if a name is not given" do
      select "Member", from: "Membership type"
      click_button "Invite member"
      page.should have_content("Please enter a name")
    end
  end
end
