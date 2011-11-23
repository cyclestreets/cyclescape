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

    it "should store the request URL with the comment" do
      click_on "Feedback"
      fill_in "Message", with: "This page broke!"
      click_on "Send Feedback"
      SiteComment.last.context_url.should == root_url
    end

    it "should store the user if someone is logged in"
  end

  context "as a site user" do
    include_context "signed in as a site user"
    let!(:comment) { FactoryGirl.create(:site_comment) }

    it "should not let you browse the feedback" do
      visit site_comments_path
      page.should have_content("You are not authorised to access that page.")
    end
  end

  context "as an admin" do
    include_context "signed in as admin"
    let!(:comment) { FactoryGirl.create(:site_comment) }

    it "should show the comments" do
      visit site_comments_path
      page.should have_content(comment.body[0..51]) #chokes on newline
    end
  end
end
