# frozen_string_literal: true

require "spec_helper"

describe "Group profiles" do
  context "as a public user" do
    describe "viewing the group profile" do
      let(:group) { create(:group) }

      before do
        # FIXME: Work around - hard to get group + group_profile via factories
        group.profile.description = "This is a group of people."
        group.profile.location = "POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))"
        group.profile.save!
      end

      it "should show you the profile" do
        visit group_profile_path(group)
        expect(page).to have_content(group.profile.description)
      end
    end
  end

  context "as a group member" do
    include_context "signed in as a group member"

    describe "editing the group profile" do
      it "should refuse" do
        visit edit_group_profile_path(current_group)
        expect(page).to have_content(I18n.t("shared.permission_denied.login"))
      end
    end
  end

  context "as a group committee member" do
    include_context "signed in as a committee member"

    describe "editing the group profile" do
      it "should be permitted" do
        visit edit_group_profile_path(current_group)
        expect(page).to have_content("Edit Profile")
      end

      it "should work" do
        visit edit_group_profile_path(current_group)
        fill_in "Description", with: "Updated description"
        click_on "Save"
        visit group_profile_path(current_group)
        expect(page).to have_content("Updated description")
      end
    end
  end

  context "as a site admin" do
    include_context "signed in as admin"

    describe "editing any group profile she wants to" do
      let(:group) { create(:quahogcc) }
      it "should be permitted" do
        visit edit_group_profile_path(group)
        expect(page).to have_content("Edit Profile")
      end
    end
  end
end
