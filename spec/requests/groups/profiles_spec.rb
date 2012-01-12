require "spec_helper"

describe "Group profiles" do
  context "as a group member" do
    include_context "signed in as a group member"

    describe "editing the group profile" do
      it "should refuse" do
        visit edit_group_profile_path(current_group)
        page.should have_content("You are not authorised to access that page.")
      end
    end
  end

  context "as a group committee member" do
    include_context "signed in as a committee member"

    describe "editing the group profile" do
      it "should be permitted" do
        visit edit_group_profile_path(current_group)
        page.should have_content("Edit Profile")
      end
    end
  end

  context "as a site admin" do
    include_context "signed in as admin"

    describe "editing any group profile she wants to" do
      let(:group) { FactoryGirl.create(:quahogcc) }
      it "should be permitted" do
        visit edit_group_profile_path(group)
        page.should have_content("Edit Profile")
      end
    end
  end
end