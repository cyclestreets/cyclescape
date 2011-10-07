require "spec_helper"

describe "Issues" do

  let!(:issue_category) { FactoryGirl.create(:issue_category) }
  let(:issue_values) { FactoryGirl.attributes_for(:issue_with_json_loc) }

  context "new" do
    context "as site member" do
      include_context "signed in as a site user"

      before do
        visit new_issue_path
      end

      it "should create a new issue" do
        fill_in "Title", with: issue_values[:title]
        select "Bike Parking", from: "Category"
        fill_in "Description", with: issue_values[:description]
        # Note hidden map field
        find("#issue_loc_json").set(issue_values[:loc_json])
        click_on "Create Issue"
        within(".content header") do
          page.should have_content(issue_values[:title])
        end
        page.should have_content("Bike Parking")
        page.should have_content(current_user.name)
      end
    end
  end

  context "show" do
    let!(:issue) { FactoryGirl.create(:issue, category: issue_category) }

    before do
      visit issue_path(issue)
    end

    it "should show the issue title" do
      page.should have_content(issue.title)
    end

    it "should show the description" do
      page.should have_content(issue.description)
    end

    it "should show the location"

    it "should show the category" do
      page.should have_content(issue.category.name)
    end

    context "as a site user" do
      include_context "signed in as a site user"

      it "should have a link to create a new public thread" do
        page.should have_link("New Public Thread")
      end
    end

    context "as a group member" do
      include_context "signed in as a group member"

      it "should have a link to create a new public thread" do
        page.should have_link("New Public Thread")
      end

      it "should have a link to create a new thread for the user's group" do
        page.should have_link("New #{current_user.groups.first.name} Thread")
      end
    end
  end
end
