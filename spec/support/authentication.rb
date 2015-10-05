shared_context 'signs in' do
  include Capybara::DSL
  before do
    visit new_user_session_path
    fill_in 'Email', with: current_user.email
    fill_in 'Password', with: password
    click_button 'Sign in'
    expect(page).to have_content(I18n.t('.devise.sessions.signed_in'))
  end
end

shared_context 'signed in as admin', as: :admin do
  include_context 'signs in'

  let!(:current_user) { create(:stewie) }
  let!(:password) { attributes_for(:stewie)[:password] }
end

shared_context 'signed in as a committee member', as: :committee_member do
  include_context 'signs in'

  let!(:membership) { create(:brian_at_quahogcc) }
  let!(:password) { attributes_for(:brian)[:password] }
  let(:current_group) { membership.group }
  let(:current_user) { membership.user }
end

shared_context 'signed in as a group member', as: :group_member do
  include_context 'signs in'

  let!(:membership) { create(:chris_at_quahogcc) }
  let!(:password) { attributes_for(:chris)[:password] }
  let(:current_group) { membership.group }
  let(:current_user) { membership.user }
end

shared_context 'signed in as a site user', as: :site_user do
  include_context 'signs in'

  # Slightly different as user factory uses a sequence for password
  # so we need to get the password at the same time
  let!(:user_details) { attributes_for(:user) }
  let!(:current_user) { create(:user, user_details) }
  let!(:password) { user_details[:password] }
end
