# frozen_string_literal: true

require "spec_helper"

describe "Deadline messages" do
  let(:thread) { create(:message_thread) }
  let(:future_date) { Date.current + 5.days }

  def deadline_form
    within("#new-deadline-message") { yield }
  end

  context "new", as: :site_user do
    before do
      visit thread_path(thread)
    end

    it "opens datepicker modal before and after posting", js: true do
      stub_request(:post, "https://development.rest.akismet.com/1.1/comment-check").to_return(status: 200, body: "false")
      click_on "Deadline/date"
      expect(page).to have_no_css(".ui-datepicker")
      find("#message_deadline_messages_attributes_0_deadline").click
      expect(page).to have_css(".ui-datepicker")

      fill_in "Deadline", with: future_date.to_s
      fill_in "Title", with: "Submission deadline"

      click_on "Post Message"

      wait_for_ajax

      expect(page).to have_no_css(".ui-datepicker")
      find("#message_deadline_messages_attributes_0_deadline").click
      expect(page).to have_css(".ui-datepicker")
    end

    it "should post a new deadline message" do
      future_date = Date.current + 5.days
      deadline_form do
        fill_in "Deadline", with: future_date.to_s
        fill_in "Title", with: "Submission deadline"
      end
      click_on "Post Message"
      expect(page).to have_content(future_date.strftime("%A, %d %B %Y %l:%M %p"))
      expect(page).to have_content("Submission deadline")
    end
  end
end
