require 'spec_helper'

describe 'Authentication and authorization' do
  context 'when not logged in' do
    it 'should allow access to the home page' do
      visit root_path
      expect(page.status_code).to eq(200)
      expect(page.current_path).to eq(root_path)
    end

    it 'should not allow access to groups and redirect to sign-in' do
      visit admin_groups_path
      expect(page.current_path).to eq(new_user_session_path)
    end
  end

  context 'when visiting a page that requires login' do
    let!(:user_details) { attributes_for(:user) }
    let!(:current_user) { create(:user, user_details) }
    let!(:password) { user_details[:password] }

    it 'should redirect you to the original page after login' do
      visit new_issue_path
      expect(page.current_path).to eql(new_user_session_path)
      fill_in 'Email', with: current_user.email
      fill_in 'Password', with: password
      click_button 'Sign in'

      expect(page).to have_content(I18n.t('.devise.sessions.signed_in'))
      expect(page.current_path).to eql(new_issue_path)
    end
  end

  context 'when choosing to log in' do
    def choose_to_log_in_from(path)
      credentials = attributes_for(:user)
      create(:user, credentials)
      visit path
      click_link 'Sign in'
      fill_in 'Email', with: credentials[:email]
      fill_in 'Password', with: credentials[:password]
      click_button 'Sign in'
    end

    it 'should direct you to your dashboard page instead of homepage' do
      choose_to_log_in_from(root_path)
      expect(page.current_path).to eq(dashboard_path)
    end

    it 'should otherwise direct you page to where you started' do
      choose_to_log_in_from(issues_path)
      expect(page.current_path).to eq(issues_path)
    end
  end

  describe 'remember subdomains when logging in' do
    include_context 'signed in as a group member'
    let(:group_url) { "http://#{current_group.short_name}.example.com/" }

    def switch_to_group_and_sign_out
      within '.group-selector' do
        click_on current_group.name
      end
      expect(page.current_url).to eq(group_url)
      click_on 'Sign out'
      expect(page).to have_no_content(current_user.name)
    end

    it 'should return me to my last-used subdomain' do
      switch_to_group_and_sign_out
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: current_user.email
      fill_in 'Password', with: password
      click_button 'Sign in'
      expect(page.current_url).to eq(dashboard_url(subdomain: current_group.short_name))
    end

    it "should not blow up if the group doesn't exist" do
      switch_to_group_and_sign_out
      current_group.destroy
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: current_user.email
      fill_in 'Password', with: password
      click_button 'Sign in'
      expect(page.current_url).to eq(dashboard_url(subdomain: 'www'))
    end
  end

  context 'when signing up' do
    before do
      @credentials = attributes_for(:user)
      visit root_path
      click_link 'Sign up'
      fill_in 'Full name', with: @credentials[:full_name]
      fill_in 'Email', with: @credentials[:email]
      fill_in 'Password', with: @credentials[:password], match: :first
      fill_in 'Password confirmation', with: @credentials[:password]
      click_button 'Sign up'
      open_email(@credentials[:email])
    end

    it 'should direct you to your locations page' do
      visit_in_email('Confirm my account')
      fill_in 'Password', with: @credentials[:password], match: :first
      fill_in 'Email', with: @credentials[:email]
      click_button 'Sign in'
      expect(page.current_path).to eq(current_user_locations_path)
    end

    it 'should resend your confirmation email, if you ask for it' do
      expect(all_emails.count).to eql(1)
      visit new_user_session_path
      click_link "Didn't receive confirmation instructions?"
      fill_in 'Email', with: @credentials[:email]
      click_button 'Resend confirmation instructions'
      expect(all_emails.count).to eql(2)
    end
  end

  context 'when closing my account' do
    let!(:user_details) { attributes_for(:user) }
    let!(:current_user) { create(:user, user_details) }
    let!(:password) { user_details[:password] }

    def sign_in
      visit new_user_session_path
      fill_in 'Email', with: current_user.email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    def cancel_account
      visit edit_user_registration_path
      click_on I18n.t('.devise.registrations.edit.cancel_account')
    end

    it 'should tell me the account has been cancelled' do
      sign_in
      cancel_account
      expect(page.current_path).to eq(root_path)
      expect(page).to have_content(I18n.t('.devise.registrations.destroyed'))
    end

    it 'should log me out' do
      sign_in
      cancel_account
      visit dashboard_path
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end

    it 'should not let me log back in' do
      sign_in
      cancel_account
      sign_in
      expect(page).to have_content(I18n.t('.devise.failure.not_found_in_database'))
    end

    it 'should not let me recover my password' do
      sign_in
      cancel_account
      visit new_user_password_path
      fill_in 'Email', with: user_details[:email]
      click_on I18n.t('.devise.passwords.new.send_reset_instuctions')
      expect(page).to have_content 'Email not found'
    end
  end
end
