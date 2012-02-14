require "spec_helper"

describe "Issue notifications" do
  include_context "signed in as a site user"

  let(:issue_values) { FactoryGirl.attributes_for(:issue_with_json_loc) }

  context "on a new issue" do
    describe "for users with overlapping issues" do
      let(:user) { FactoryGirl.create(:user) }
      let!(:user_location) { FactoryGirl.create(:user_location, user: user, loc_json: issue_values[:loc_json]) }

      before do
        user.prefs.update_attribute(:notify_new_user_locations_issue, true)
      end

      it "should send a notification" do
        visit new_issue_path
        fill_in "Title", with: issue_values[:title]
        fill_in "Write a description", with: issue_values[:description]
        find("#issue_loc_json").set(issue_values[:loc_json])
        click_on "Send Report"
        page.should have_content(issue_values[:title])
        category_name = user_location.category.name.downcase
        email = open_last_email_for(user_location.user.email)
        email.should have_subject("[Cyclescape] New issue reported near your #{category_name} location")
      end

      it "should not include html entities in the subject" do
        visit new_issue_path
        fill_in "Title", with: "Test containing A & B"
        fill_in "Write a description", with: issue_values[:description]
        find("#issue_loc_json").set(issue_values[:loc_json])
        click_on "Send Report"
        email = open_last_email_for(user_location.user.email)
        email.should_not have_body_text("&amp;")
        email.should have_body_text(/Test containing A & B/)
      end
    end
  end
end
