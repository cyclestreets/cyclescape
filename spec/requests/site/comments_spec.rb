require "spec_helper"

describe "Site feedback" do
  before do
    visit root_path
  end

  context "as a public user", user: :public do
    it "should be able to see the feedback link" do
      page.should have_link("Feedback")
    end

    it "should be able to send feedback" do
      click_on "Feedback"
      fill_in "Message", with: "Your site is awesome!"
      fill_in "Name", with: "Bobby Jones"
      fill_in "Email", with: "bobby@example.com"
      click_on "Send Feedback"
      page.should have_content("Thank you")
    end
  end
end
