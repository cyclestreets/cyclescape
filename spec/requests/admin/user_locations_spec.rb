require "spec_helper"

describe "Groups admin" do
  include_context "signed in as admin"

  let(:user) { FactoryGirl.create(:user) }
  let!(:location) { FactoryGirl.create(:user_location, user: user) }

  let!(:location_category) { FactoryGirl.create(:location_category) }
  let(:location_attributes) { FactoryGirl.attributes_for(:user_location_with_json_loc) }

  it "should let you view the list of user locations" do
    visit admin_user_locations_path(user)
    page.should have_content(location.category.name)
  end

  it "should let you add a new user location" do
    visit admin_user_locations_path(user)
    click_on I18n.t(".admin.user.locations.index.new")
    page.should have_content(I18n.t(".admin.user.locations.new.title", user_name: user.name))
    select location_category.name, from: "Category"
    # Note hidden map field
    find("#user_location_loc_json").set(location_attributes[:loc_json])
    click_on I18n.t(".formtastic.actions.user_location.create")

    page.should have_content("Location Created")
    page.should have_content(location_category.name)

    # Check we haven't created the location against the admin account!
    current_user.locations.length.should eq(0)
  end
end
