require "spec_helper"

describe "Authentication and authorization" do
  context "when not logged in" do
    it "should allow access to the home page" do
      visit root_path
      page.status_code.should == 200
      page.current_path.should == root_path
    end

    it "should not allow access to groups and redirect to sign-in" do
      visit admin_groups_path
      page.current_path.should == new_user_session_path
    end
  end

  context "when visiting a page that requires login" do
    let!(:user_details) { FactoryGirl.attributes_for(:user) }
    let!(:current_user) { FactoryGirl.create(:user, user_details) }
    let!(:password) { user_details[:password] }

    it "should redirect you to the original page after login" do
      visit new_issue_path
      page.current_path.should eql(new_user_session_path)
      fill_in "Email", with: current_user.email
      fill_in "Password", with: password
      click_button "Sign in"

      page.should have_content("signed in")
      page.current_path.should eql(new_issue_path)
    end
  end

  context "when logging in" do
    it "should direct you to your dashboard page" do
      credentials = FactoryGirl.attributes_for(:user)
      user = FactoryGirl.create(:user, credentials)
      visit root_path
      click_link "Sign in"
      fill_in "Email", with: credentials[:email]
      fill_in "Password", with: credentials[:password]
      click_button "Sign in"
      page.current_path.should == dashboard_path
    end
  end

  describe "remember subdomains when logging in" do
    include_context "signed in as a group member"

    it "should return me to my last-used subdomain" do
      group_url = "http://#{current_group.short_name}.example.com/"
      within ".group-selector" do
        click_on current_group.name
      end
      page.current_url.should == group_url
      click_on "Sign out"
      visit root_path
      click_link "Sign in"
      fill_in "Email", with: current_user.email
      fill_in "Password", with: password
      click_button "Sign in"
      page.current_url.should == group_url
    end
  end

  context "when signing up" do
    before do
      @credentials = FactoryGirl.attributes_for(:user)
      visit root_path
      click_link "Sign up"
      fill_in "Full name", with: @credentials[:full_name]
      fill_in "Email", with: @credentials[:email]
      fill_in "Password", with: @credentials[:password]
      fill_in "Password confirmation", with: @credentials[:password]
      click_button "Sign up"
      open_email(@credentials[:email])
    end

    it "should direct you to your locations page" do
      visit_in_email("Confirm my account")
      page.current_path.should == user_locations_path
    end

    it "should resend your confirmation email, if you ask for it" do
      all_emails.count.should eql(1)
      visit new_user_session_path
      click_link "Didn't receive confirmation instructions?"
      fill_in "Email", with: @credentials[:email]
      click_button "Resend confirmation instructions"
      all_emails.count.should eql(2)
    end
  end
end
