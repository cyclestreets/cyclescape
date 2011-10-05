shared_context "signs in" do
  before do
    visit new_user_session_path
    fill_in "Email", with: current_user.email
    fill_in "Password", with: password
    click_button "Sign in"
    page.should have_content("Signed in")
  end
end

shared_context "signed in as admin" do
  include_context "signs in"

  let!(:current_user) { FactoryGirl.create(:stewie) }
  let!(:password) { FactoryGirl.attributes_for(:stewie)[:password] }
end

shared_context "signed in as a committee member" do
  include_context "signs in"

  let!(:membership) { FactoryGirl.create(:brian_at_quahogcc) }
  let!(:password) { FactoryGirl.attributes_for(:brian)[:password] }
  let(:current_group) { membership.group }
  let(:current_user) { membership.user }
end

shared_context "signed in as a group member" do
  include_context "signs in"

  let!(:membership) { FactoryGirl.create(:stewie_at_quahogcc) }
  let!(:password) { FactoryGirl.attributes_for(:stewie)[:password] }
  let(:current_group) { membership.group }
  let(:current_user) { membership.user }
end

shared_context "signed in as a site user" do
  include_context "signs in"

  let!(:current_user) { FactoryGirl.create(:user) }
  let!(:password) { FactoryGirl.attributes_for(:user)[:password] }
end
