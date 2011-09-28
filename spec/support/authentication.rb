shared_context "signed in as admin" do
  before do
    @admin = FactoryGirl.create(:admin)
    visit new_user_session_path
    fill_in "Email", with: @admin.email
    fill_in "Password", with: "Victory is mine!"
    click_button "Sign in"
  end
end
