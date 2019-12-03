# frozen_string_literal: true

require "spec_helper"

describe "Poll messages" do
  let(:thread) { create(:message_thread) }

  def link_form
    within("#new-poll-message") { yield }
  end

  context "new", as: :site_user do
    before do
      visit thread_path(thread)
    end

    it "should post and vote on a poll message", js: true do
      click_on "Poll"
      link_form do
        fill_in "Question", with: "Why oh why?"
        fill_in "message_poll_messages_attributes_0_poll_options_attributes_0_option", with: "Option A"
        fill_in "message_poll_messages_attributes_0_poll_options_attributes_1_option", with: "Option B"
        expect(page).to have_no_css("i.fa.fa-minus-circle") # No remove element
        find(:css, "i.fa.fa-plus-circle").find(:xpath, "..").click # Add another options form element
        expect(page).to have_css("i.fa.fa-minus-circle", count: 3) # Now we have 3 remove elements
        within all(".nested-fields").last do
          fill_in "Option", with: "Option C"
        end
      end
      click_on "Post Message"

      sleep(0.4)

      expect(page).to have_content("Why oh why?")
      expect(page).to have_content("Option A [0 votes]")
      expect(page).to have_content("Option B [0 votes]")
      expect(page).to have_content("Option C [0 votes]")
      choose("Option C")
      sleep(0.4)
      expect(page).to have_content("Option A [0 votes]")
      expect(page).to have_content("Option B [0 votes]")
      expect(page).to have_content("Option C [1 vote]")
    end
  end
end
