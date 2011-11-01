require "spec_helper"

describe "User profiles" do
  let(:user) { FactoryGirl.create(:stewie_with_profile) }

  it "should display Stewie's profile" do
    visit user_profile_path(user)
    current_path.should == "/users/#{user.id}-#{user.name.parameterize}/profile"
    page.should have_content(user.name)
  end

  context "edit", as: :site_user do
    before do
      visit edit_user_profile_path(current_user)
    end

    it "should upload a picture" do
      attach_file "Picture", profile_photo_path
      click_on "Save"
      current_user.profile.picture.should be_true
    end

    it "should set the website address" do
      fill_in "Website", with: "www.example.net"
      click_on "Save"
      current_user.profile.website.should == "http://www.example.net"
    end

    it "should set the biography" do
      fill_in "About", with: lorem_ipsum
      click_on "Save"
      current_user.profile.about.should == lorem_ipsum
    end
  end
end
