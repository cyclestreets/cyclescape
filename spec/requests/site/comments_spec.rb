require "spec_helper"

describe "Site feedback" do
  before do
    visit root_path
  end

  context "as a public user" do
    it "should be able to see the feedback link" do
      page.should have_link("Send us beta feedback")
    end

    it "should be able to send feedback" do
      click_on "Send us beta feedback"
      fill_in "Message", with: "Your site is awesome!"
      fill_in "Name", with: "Bobby Jones"
      fill_in "Email", with: "bobby@example.com"
      click_on "Send Feedback"
      page.should have_content("Thank you")
    end

    it "should store the request URL with the comment" do
      click_on "Send us beta feedback"
      fill_in "Message", with: "This page broke!"
      click_on "Send Feedback"
      SiteComment.last.context_url.should == root_url
    end
  end

  context as: :site_user do
    it "should not let you browse the feedback" do
      visit site_comments_path
      page.should have_content("You are not authorised to access that page.")
    end
  end

  context as: :admin do
    let!(:comment) { FactoryGirl.create(:site_comment) }

    it "should show the comments" do
      visit site_comments_path
      page.should have_content(comment.body[0..51]) #chokes on newline
    end
  end
end
