require "spec_helper"

describe "Issue notifications" do
  include_context "signed in as a site user"

  let(:issue_values) { FactoryGirl.attributes_for(:issue_with_json_loc) }

  context "on a new issue" do
    describe "for users with overlapping issues" do
      let(:user_location) { FactoryGirl.create(:user_location, loc_json: issue_values[:loc_json]) }

      it "should send a notification" do
        visit new_issue_path
        fill_in "Title", with: issue_values[:title]
        fill_in "Write a description", with: issue_values[:description]
        find("#issue_loc_json").set(issue_values[:loc_json])
        click_on "Send Report"
        page.should have_content(issue_values[:title])
        category_name = user_location.category.name
        email = open_last_email_for(current_user.email)
        email.should have_subject("[Cyclescape] New issue reported near your #{category_name} location")
      end
    end
  end
end
