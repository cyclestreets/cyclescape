require "spec_helper"

describe "User locations" do

  let!(:location_category) { FactoryGirl.create(:location_category) }
  let(:location_attributes) { FactoryGirl.attributes_for(:user_location_with_json_loc) }

  context "view" do
    include_context "signed in as a site user"

    it "should show a page for a new user" do
      visit user_locations_path
      page.should have_content("My Locations")
    end

    it "should let you add a new location" do
      visit new_user_location_path
      page.should have_content("New Location")
      select "Route to School", from: "Category"
      # Note hidden map field
      find("#user_location_loc_json").set(location_attributes[:loc_json])
      click_on "Create User location"

      page.should have_content("Location Created")
      page.should have_content("Route to School")
    end
  end
end