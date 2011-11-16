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

      page.should have_content("Signed in")
      page.current_path.should eql(new_issue_path)
    end
  end
end
