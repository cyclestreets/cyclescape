require 'spec_helper'

describe Group::MembersController do
  describe "index" do
    before do
      @group = FactoryGirl.create(:group)
      @memberships = FactoryGirl.create_list(:group_membership, 4, group: @group)
      visit group_members_path(@group)
    end

    it "shows the group name" do
      page.should have_content(@group.name)
    end

    it "lists the member names do" do
      @memberships.each do |member|
        page.should have_content(member.user.name)
      end
    end
  end
end
