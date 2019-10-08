# frozen_string_literal: true

require "spec_helper"

describe "Action messages" do
  let(:thread) { create(:message_thread, :belongs_to_issue) }
  let(:user) { create :user }

  def action_form
    within("#new-action-message") { yield }
  end

  def message_form; end

  context "new" do
    include_context "signed in as a site user"

    before do
      user.prefs.update_column(:email_status_id, 1)
      thread.subscriptions.find_or_create_by(user: user)
      visit thread_path(thread)
    end

    it "should post a map message and send an email" do
      action_form do
        fill_in "Description", with: "Something must be done!"
      end
      click_on "Post Message"

      within(".action-message") do
        expect(page).to have_content("Something must be done!")
      end

      open_email(user.email)
      expect(current_email).to have_subject("[Cyclescape] #{thread.title}")
      expect(current_email).to have_body_text(/Something must be done!/)

      within(first("#new_message")) do
        fill_in "message_body", with: "I've done it"
        check "Something must be done!"
        click_on "Post Message"
      end

      expect(page).to have_content "I've done it"
      expect(page).to have_content I18n.t("shared.actions.resolve_action")
      expect(page).to have_content "Something must be done!"

      expect(last_email_sent).to have_subject("Re: [Cyclescape] #{thread.title}")
      expect(last_email_sent).to have_body_text(/Resolves actions:/)
      expect(last_email_sent).to have_body_text(/Something must be done!/)
      expect(last_email_sent).to have_body_text(/I've done it/)
    end
  end
end
