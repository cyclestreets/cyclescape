require 'spec_helper'

describe "Group members" do
  include_context "signed in as admin"

  before do
    @group = FactoryGirl.create(:group)
  end

  context "index" do
    before do
      @memberships = FactoryGirl.create_list(:group_membership, 4, group: @group)
      visit group_members_path(@group)
    end

    it "should display the user name" do
      page.should have_content("Stewie")
    end

    it "lists the member names" do
      @memberships.each do |member|
        page.should have_content(member.user.name)
      end
    end

    it "should have a link to create a new member" do
      find_link('New Member').should be_visible
    end
  end
end
