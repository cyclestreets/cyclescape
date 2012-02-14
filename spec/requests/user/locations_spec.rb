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
      select location_category.name, from: "Category"
      # Note hidden map field
      find("#user_location_loc_json").set(location_attributes[:loc_json])
      click_on "Create User location"

      page.should have_content("Location Created")
      page.should have_content(location_category.name)
    end

    context "edit" do
      let!(:location) { FactoryGirl.create(:user_location, user: current_user, category: location_category) }

      it "should let you edit an existing location" do
        visit user_locations_path
        click_on "Edit" # hmm, edit the right one?

        page.should have_content("Edit Location")
        find("#user_location_loc_json").set(location_attributes[:loc_json])
        click_on "Save"

        page.should have_content("Location Updated")
      end

      it "should let you delete a location" do
        visit user_locations_path
        click_on "Delete"
        page.should have_content("Location deleted")
      end
    end
  end
end