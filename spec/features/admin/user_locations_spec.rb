require 'spec_helper'

describe 'Groups admin' do
  include_context 'signed in as admin'

  let(:user) { create(:user) }
  let!(:location) { create(:user_location, user: user) }

  let!(:location_category) { create(:location_category) }
  let(:location_attributes) { attributes_for(:user_location_with_json_loc) }

  it 'should let you add a new user location' do
    visit admin_user_locations_path(user)
    click_on I18n.t('.admin.user.locations.index.new')
    expect(page).to have_content(I18n.t('.admin.user.locations.new.title', user_name: user.name))
    # Note hidden map field
    find('#user_location_loc_json', visible: false).set(location_attributes[:loc_json])
    click_on I18n.t('.formtastic.actions.user_location.create')

    expect(page).to have_content('Location Created')

    # Check we haven't created the location against the admin account!
    expect(current_user.location).to be_nil
  end
end
