# frozen_string_literal: true

require "spec_helper"

describe "Multi-component message", type: :feature do
  let(:thread) { create(:message_thread, :belongs_to_issue) }
  let(:user) { create :user }

  context "posting a multi-component message" do
    include_context "signed in as a site user"

    before do
      user.prefs.update_column(:email_status_id, 1)
      thread.subscriptions.find_or_create_by(user: user)
      visit thread_path(thread)
    end

    it "updates the page remotely and sends an email", js: true do
      stub_request(:post, "https://development.rest.akismet.com/1.1/comment-check").to_return(status: 200, body: "false")
      future_date = Date.current + 5.days

      click_on "Attachment"
      attach_file("File", pdf_document_path)
      fill_in "Title", with: "An important document"

      click_on "Call to action"
      fill_in "Description", with: "Something must be done!"

      click_on "Deadline/date"
      fill_in "Deadline", with: future_date.to_s
      fill_in "Title", with: "Submission deadline"

      click_on "Map"
      fill_in "Caption", with: "A fine map"
      geojson = '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.1250070333480835,52.20619176430142]}}]}'
      page.execute_script("$('#message_map_messages_attributes_0_loc_json').val('#{geojson}')")

      click_on "Photo"
      attach_file("Photo", abstract_image_path)
      fill_in "Caption", with: "An abstract image"

      click_on "Post Message"

      wait_for_ajax

      expect(Message.last.components.count).to eq(5)

      expect(page).to have_content("An important document")
      expect(page).to have_link("Download Attachment")

      expect(page).to have_content(future_date.strftime("%A, %d %B %Y %l:%M %p"))

      expect(page).to have_content("A fine map")
      within(".action-message") do
        expect(page).to have_content("Something must be done!")
      end

      open_email(user.email)
      expect(current_email).to have_subject("[Cyclescape] #{thread.title}")
      expect(current_email).to have_body_text(/A fine map/)
      expect(current_email).to have_body_text(%r{threads/#{thread.id}#message_#{Message.last.id}})
      expect(current_email).to have_body_text(/Something must be done!/)
    end
  end
end
