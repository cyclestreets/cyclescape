# frozen_string_literal: true

require "spec_helper"

describe "Map messages" do
  let(:thread) { create(:message_thread, :belongs_to_issue) }
  let(:user) { create :user }

  def map_form
    within("#new-map-message") { yield }
  end

  context "new" do
    include_context "signed in as a site user"

    before do
      user.prefs.update_column(:email_status_id, 1)
      thread.subscriptions.find_or_create_by(user: user)
      visit thread_path(thread)
    end

    it "should post a map message and send an email" do
      map_form do
        fill_in "Caption", with: "A fine map"
        find("#message_map_messages_attributes_0_loc_json", visible: false).set('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.1250070333480835,52.20619176430142]}}]}')
      end
      click_on "Post Message"

      expect(page).to have_css(".map-normal-show")

      within("figcaption") do
        expect(page).to have_content("A fine map")
      end

      open_email(user.email)
      expect(current_email).to have_subject("[Cyclescape] #{thread.title}")
      expect(current_email).to have_body_text(/A fine map/)
      expect(current_email).to have_body_text(%r{threads/#{thread.id}#message_#{Message.last.id}})
    end
  end
end
