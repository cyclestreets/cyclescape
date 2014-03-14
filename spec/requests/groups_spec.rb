# encoding: UTF-8
require "spec_helper"

describe "Groups" do
  let(:profile) { FactoryGirl.create(:group_profile) }

  describe "show" do
    before do
      visit group_path(profile.group)
    end

    it "should show the name of the group" do
      page.should have_content(profile.group.name)
    end

    it "should show the group description" do
      page.should have_content(profile.description)
    end

    it "should not show the joining instructions" do
      page.should_not have_content(profile.joining_instructions)
    end

    it "should autolink the group description" do
      profile.update_attribute(:description, "contains a link: http://www.example.com")
      visit group_path(profile.group)

      page.should have_link("http://www.example.com")
    end

    context "logged in user" do
      include_context "signed in as a site user"

      it "should show joining instructions" do
        page.should have_content(profile.joining_instructions)
      end

      it "should show default joining instructions if none are set" do
        profile.joining_instructions = nil
        profile.save!
        visit group_path(profile.group)

        page.should have_content(I18n.t("groups.join.join_body" , group: profile.group.name))
      end
    end
  end

  describe "index" do
    let!(:profile_2) { FactoryGirl.create(:group_profile) }
    let!(:profile_3) { FactoryGirl.create(:group_profile) }

    before do
      visit groups_path
    end

    it "should show both group names" do
      page.should have_content(profile_2.group.name)
      page.should have_content(profile_3.group.name)
    end
  end
end
