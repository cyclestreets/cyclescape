shared_context "signed in as admin" do
  let!(:admin) { FactoryGirl.create(:stewie) }
  let!(:password) { FactoryGirl.attributes_for(:stewie)[:password] }

  before do
    visit new_user_session_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: password
    click_button "Sign in"
    page.should have_content("Signed in")
  end
end

shared_context "signed in as a committee member" do
  let!(:membership) { FactoryGirl.create(:brian_at_quahogcc) }
  let!(:password) { FactoryGirl.attributes_for(:brian)[:password] }
  let(:current_group) { membership.group }
  let(:current_user) { membership.user }

  before do
    visit new_user_session_path
    fill_in "Email", with: current_user.email
    fill_in "Password", with: password
    click_button "Sign in"
    page.should have_content("Signed in")
  end
end
