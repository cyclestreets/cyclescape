require 'spec_helper'

describe 'User locations' do

  let!(:location_category) { FactoryGirl.create(:location_category) }
  let(:location_attributes) { FactoryGirl.attributes_for(:user_location_with_json_loc) }

  context 'view' do
    include_context 'signed in as a site user'

    it 'should show a page for a new user' do
      visit user_locations_path
      page.should have_content('My Locations')
    end

    it 'should let you add a new location' do
      visit new_user_location_path
      page.should have_content(I18n.t('.user.locations.new.new_location'))
      select location_category.name, from: 'Category'
      # Note hidden map field
      find('#user_location_loc_json').set(location_attributes[:loc_json])
      click_on I18n.t('.formtastic.actions.user_location.create')

      page.should have_content('Location Created')
      page.should have_content(location_category.name)
    end

    context 'with a location' do
      let!(:location) { FactoryGirl.create(:user_location, user: current_user) }

      def guidance_text(key)
        I18n.t(".user.locations.index#{key}", edit_prefs_link: I18n.t('.user.locations.index.edit_your_prefs'))
      end

      it 'should give appropriate guidance based on your settings' do
        current_user.prefs.update_column(:involve_my_locations, 'none')
        visit user_locations_path
        page.should have_content(guidance_text('.combined_locations_guidance_none_html'))

        current_user.prefs.update_column(:involve_my_locations, 'notify')
        visit user_locations_path
        page.should have_content(guidance_text('.combined_locations_guidance_notify_html'))

        current_user.prefs.update_column(:involve_my_locations, 'subscribe')
        visit user_locations_path
        page.should have_content(guidance_text('.combined_locations_guidance_subscribe_html'))
      end
    end

    context 'edit' do
      let!(:location) { FactoryGirl.create(:user_location, user: current_user, category: location_category) }

      it 'should let you edit an existing location' do
        visit user_locations_path
        click_on 'Edit' # hmm, edit the right one?

        page.should have_content('Edit Location')
        find('#user_location_loc_json').set(location_attributes[:loc_json])
        click_on 'Save'

        page.should have_content('Location Updated')
      end

      it 'should let you delete a location' do
        visit user_locations_path
        click_on 'Delete'
        page.should have_content('Location deleted')
      end
    end

    context 'catching up on threads' do
      let!(:location) { FactoryGirl.create(:user_location, user: current_user) }

      it 'should subscribe you to threads' do
        current_user.prefs.update_column(:involve_my_locations, 'none')
        issue = FactoryGirl.create(:issue, location: current_user.buffered_locations.centroid)
        Issue.intersects(current_user.buffered_locations).should_not be_empty
        thread = FactoryGirl.create(:message_thread, issue: issue)
        current_user.subscribed_to_thread?(thread).should be_false

        visit user_locations_path
        click_on I18n.t('.user.locations.index.subscribe_existing_threads')

        page.should have_content(I18n.t('.user.locations.subscribe_to_threads.subscribed_to_threads', count: 1))
        current_user.subscribed_to_thread?(thread).should be_true
      end
    end
  end
end
