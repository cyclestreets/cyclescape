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
        email.should have_body_text(issue_values[:title])
        email.should have_body_text(issue_values[:description])
      end

      it "should not include html entities in the message" do
        visit new_issue_path
        fill_in "Title", with: "Test containing A & B"
        fill_in "Write a description", with: "Something & something else"
        find("#issue_loc_json").set(issue_values[:loc_json])
        click_on "Send Report"
        email = open_last_email_for(user_location.user.email)
        email.should_not have_body_text("&amp;")
        email.should have_body_text(/Test containing A & B/)
      end
    end
  end

  context "multiple overlapping locations" do
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let!(:user_location) { FactoryGirl.create(:user_location, user: user, location: "POLYGON ((-10 41, 10 41, 10 61, -10 61, -10 41))") }
    let!(:user_location_big) { FactoryGirl.create(:user_location, user: user, location: user_location.location.buffer(1)) }
    let!(:user_location_small) { FactoryGirl.create(:user_location, user: user, location: user_location.location.buffer(-1)) }


    before do
      user.prefs.update_attribute(:notify_new_user_locations_issue, true)
      user2.prefs.update_attribute(:notify_new_user_locations_issue, true)
      visit new_issue_path
      fill_in "Title", with: "Test"
      fill_in "Write a description", with: "Something & something else"
      find("#issue_loc_json").set(user_location.loc_json)

    end

    it "should not send multiple emails to the same user" do
      email_count = all_emails.count
      click_on "Send Report"
      all_emails.count.should eql(email_count + 1)
      open_email(user_location.user.email)
      current_email.should have_body_text(user_location_small.category.name)
      current_email.should_not have_body_text(user_location_big.category.name)
      current_email.should_not have_body_text(user_location.category.name)
    end

    context "multiple users" do
      let!(:user2_location) { FactoryGirl.create(:user_location, user: user2, location: "POLYGON ((-10 41, 10 41, 10 61, -10 61, -10 41))") }
      let!(:user2_location_big) { FactoryGirl.create(:user_location, user: user2, location: user_location.location.buffer(1)) }
      let!(:user2_location_small) { FactoryGirl.create(:user_location, user: user2, location: user_location.location.buffer(-1)) }

      it "should send one email to multiple users" do
        email_count = all_emails.count
        click_on "Send Report"
        all_emails.count.should eql(email_count + 2)
        open_email(user.email)
        current_email.should have_body_text(user_location_small.category.name)
        open_email(user2.email)
        current_email.should have_body_text(user2_location_small.category.name)
      end
    end
  end
end
