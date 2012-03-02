require "spec_helper"

describe "Issues in a group subdomain" do
  include_context "signed in as a group member"
  include_context "with current group subdomain"

  let!(:group_profile) { FactoryGirl.create(:big_group_profile, group: current_group) }

  context "index" do
    let(:location_inside_group) { "POINT (10 10)" }
    let(:location_outside_group) { "POINT (200 200)" }
    let!(:issues) { FactoryGirl.create_list(:issue, 2, location: location_inside_group) }
    let(:outside_issue) { FactoryGirl.create(:issue, location: location_outside_group) }

    it "should show issues in the group's area" do
      visit issues_path
      issues.each do |issue|
        page.should have_content(issue.title)
      end
    end

    it "should not show issues outside the group's area" do
      outside_issue
      visit issues_path
      page.should have_no_content(outside_issue.title)
    end

    it "should set the page title" do
      visit issues_path
      page.should have_selector("title", content: I18n.t("group.issues.index.title", group_name: current_group.name))
    end
  end
end
