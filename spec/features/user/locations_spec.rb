require 'spec_helper'

describe 'User locations' do

  let!(:location_category) { create(:location_category) }
  let(:location_attributes) { attributes_for(:user_location_with_json_loc) }

  context 'view' do
    include_context 'signed in as a site user'

    it 'should show a page for a new user' do
      visit current_user_locations_path
      expect(page).to have_content('My Locations')
    end

    it 'should let you add a new location' do
      visit new_user_location_path
      expect(page).to have_content(I18n.t('.user.locations.new.new_location'))
      select location_category.name, from: 'Category'
      # Note hidden map field
      find('#user_location_loc_json', visible: false).set(location_attributes[:loc_json])
      click_on I18n.t('.formtastic.actions.user_location.create')

      expect(page).to have_content('Location Created')
      expect(page).to have_content(location_category.name)
    end

    context 'with a location' do
      let!(:location) { create(:user_location, user: current_user) }

      def guidance_text(key)
        I18n.t(".user.locations.index#{key}", edit_prefs_link: I18n.t('.user.locations.index.edit_your_prefs'))
      end

      it 'should give appropriate guidance based on your settings' do
        current_user.prefs.update_column(:involve_my_locations, 'none')
        visit current_user_locations_path
        expect(page).to have_content(guidance_text('.combined_locations_guidance_none_html'))

        current_user.prefs.update_column(:involve_my_locations, 'notify')
        visit current_user_locations_path
        expect(page).to have_content(guidance_text('.combined_locations_guidance_notify_html'))

        current_user.prefs.update_column(:involve_my_locations, 'subscribe')
        visit current_user_locations_path
        expect(page).to have_content(guidance_text('.combined_locations_guidance_subscribe_html'))
      end
    end

    context 'edit' do
      let!(:location) { create(:user_location, user: current_user, category: location_category) }

      it 'should let you edit an existing location' do
        visit current_user_locations_path
        click_on 'Edit' # hmm, edit the right one?

        expect(page).to have_content('Edit Location')
        find('#user_location_loc_json', visible: false).set(location_attributes[:loc_json])
        click_on 'Save'

        expect(page).to have_content('Location Updated')
      end

      it 'should let you delete a location' do
        visit current_user_locations_path
        click_on 'Delete'
        expect(page).to have_content('Location deleted')
      end
    end
  end
end
