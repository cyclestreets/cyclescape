# frozen_string_literal: true

require "spec_helper"

describe "Site feedback" do
  before do
    visit root_path
  end

  context "as a public user" do
    it "should be able to see the feedback link" do
      expect(page).to have_link("Feedback")
    end

    it "should be able to send feedback" do
      click_on "Feedback"
      fill_in "Message", with: "Your site is awesome!"
      fill_in "Name", with: "Bobby Jones"
      fill_in "Email", with: "bobby@example.com"
      fill_in I18n.t("formtastic.labels.user.new.bicycle_wheels"), with: "8 "

      expect(SendCommentToCyclestreets).to receive(:perform).once

      click_on "Send Feedback"
      expect(page).to have_content("Thank you")

      email = ActionMailer::Base.deliveries.last
      expect(email.body).to include("bobby@example.com")
      expect(email.body).to include("Your site is awesome!")
    end

    it "should store the request URL with the comment" do
      click_on "Feedback"
      fill_in "Message", with: "This page broke!"
      fill_in I18n.t("formtastic.labels.user.new.bicycle_wheels"), with: "8 "
      click_on "Send Feedback"
      expect(SiteComment.last.context_url).to include(Capybara.default_host)
    end
  end

  context as: :site_user do
    include_context "signed in as a site user"

    it "should not let you browse the feedback" do
      visit site_comments_path
      expect(page).to have_content(I18n.t("application.permission_denied"))
    end
  end

  context as: :admin do
    let!(:comment) { create(:site_comment) }
    include_context "signed in as admin"

    it "should show the comments" do
      visit site_comments_path
      expect(page).to have_content(comment.body[0..51]) # chokes on newline
    end
  end
end
