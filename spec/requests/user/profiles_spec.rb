require "spec_helper"

describe "User profiles" do
  let(:user) { FactoryGirl.create(:stewie_with_profile) }

  it "should display Stewie's profile" do
    visit user_profile_path(user)
    current_path.should == "/users/#{user.id}-#{user.name.parameterize}/profile"
    page.should have_content(user.name)
  end

  context "edit" do
    it "should upload a picture"
    it "should set the website address"
    it "should set the biography"
  end

  context "permissions" do
    include_context "signed in as a site user"

    it "should let you edit your own profile" do
      visit edit_user_profile_path(current_user)
      page.should have_content("Edit Profile")
    end

    it "should prevent you editing someone elses" do
      visit edit_user_profile_path(user)
      page.should have_content("You are not authorised to access that page.")
    end
  end
end
