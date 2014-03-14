require "spec_helper"

# This should not test out the functionality of the devise controllers
# or models, since we assume that the Devise guys know what they are
# doing. However, when we mess up the integration, feel free to create
# corresponding tests!

describe "User accounts" do
  include_context "signed in as a site user"

  it "should let you edit your account settings" do
    visit root_path
    within("#top-menu") do
      click_on current_user.name
    end
    click_on I18n.t(".shared.profile_menu.update_account")
    page.should have_content(I18n.t(".devise.registrations.edit.title"))
  end
end
