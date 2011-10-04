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
end
