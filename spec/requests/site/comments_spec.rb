require "spec_helper"

describe "Site feedback" do
  before do
    visit root_path
  end

  context "as a public user" do
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

    it "should allow deleting" do
      SiteComment.count.should eql(1)
      visit site_comments_path
      click_on I18n.t(".site.comments.index.delete_comment")
      page.should have_content(I18n.t(".site.comments.destroy.success"))
      SiteComment.count.should eql(0)
    end
  end
end
