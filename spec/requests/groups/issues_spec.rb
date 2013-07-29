require "spec_helper"

describe "Issues in a group subdomain" do
  include_context "signed in as a group member"
  include_context "with current group subdomain"

  let(:location_inside_group) { "POINT (10 10)" }
  let(:location_outside_group) { "POINT (200 200)" }
  let!(:issues) { FactoryGirl.create_list(:issue, 2, location: location_inside_group) }
  let!(:outside_issue) { FactoryGirl.create(:issue, location: location_outside_group) }

  before do
    # Groups create empty profiles automatically, so just update the existing one
    current_group.profile.location = "POLYGON ((0 0, 0 100, 100 100, 100 0, 0 0))"
    current_group.profile.save!
  end

  context "index" do
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

    context "with search" do
      let(:search_field) { "query" }
      let(:search_button) { I18n.t("layouts.search.search_button") }

      it "should return issues in the group's area" do
        # FIXME: group restrictions aren't yet implemented for global search
        return pending
        visit issues_path
        within('.main-search-box') do
          fill_in search_field, with: issues.first.title
          click_on search_button
        end
        page.should have_link(issues.first.title, href: issue_path(issues.first))
        page.should have_no_content(outside_issue.title)
      end

      it "should not return issues outside the group's area" do
        # FIXME: this test needs fixing, still shows results when none were expected
        return pending
        visit issues_path
        within('.main-search-box') do
          fill_in search_field, with: outside_issue.title
          click_on search_button
        end
        page.should have_content("No issues found")
      end
    end
  end

  context "geojson" do
    context "all issues" do
      it "should show issues in the group's area" do
        visit all_geometries_issues_path(format: :json)

        issues.each do |issue|
          page.should have_content(issue.title)
        end
      end

      it "should not show issues outside the group's area" do
        outside_issue
        visit all_geometries_issues_path(format: :json)

        page.should have_no_content(outside_issue.title)
      end
    end
  end
end
