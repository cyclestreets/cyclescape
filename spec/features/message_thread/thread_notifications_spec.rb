# frozen_string_literal: true

require "spec_helper"

describe "thread notifications" do
  let(:thread) { create(:message_thread_with_messages) }
  let(:subscribe_button) { find_button(I18n.t("formtastic.actions.thread_subscription.create")) }

  context "new messages" do
    include_context "signed in as a site user"

    before do
      current_user.prefs.update_column(:email_status_id, 1)
      visit thread_path(thread)
      subscribe_button.click
    end

    it "should send an email for a new text message" do
      within("#new-text-message") do
        fill_in "Message", with: "Notification test"
        click_on "Post Message"
      end
      message = Message.find_by(body: "Notification test")
      open_email(current_user.email, with_subject: /^Re/)
      expect(current_email).to have_subject("Re: [Cyclescape] #{thread.title}")
      expect(current_email).to have_body_text(/Notification test/)
      expect(current_email).to have_body_text(current_user.name)
      expect(current_email).to be_delivered_from("#{current_user.name} <notifications@cyclescape.org>")
      expect(current_email).to have_reply_to("Cyclescape <message-#{message.public_token}@cyclescape.org>")
    end

    it "should send an email for a link message" do
      within("#new-link-message") do
        fill_in "Web address", with: "example.com"
        fill_in "Title", with: "An example URL"
        fill_in "Description", with: "Some words"
        click_on "Add Link"
      end
      open_email(current_user.email)
      expect(current_email).to have_body_text("http://example.com")
      expect(current_email).to have_body_text("An example URL")
      expect(current_email).to have_body_text("Some words")
    end

    it "should send an email for a deadline message" do
      within("#new-deadline-message") do
        fill_in "Deadline", with: "Wednesday, 07 December 2011" # format the date picker returns
        fill_in "Title", with: "Planning application deadline"
        click_on I18n.t("message.deadlines.new.submit")
      end
      open_email(current_user.email)
      expect(current_email).to have_body_text("Planning application deadline")
      expect(current_email).to have_body_text("Wednesday, 07 December 2011 12:00 AM") # format used in display
      expect(current_email.attachments.size).to eq(1)
      attachment = current_email.attachments[0]
      expect(attachment).to be_a_kind_of(Mail::Part)
      expect(attachment.content_type).to be_start_with("text/calendar")
    end

    context "html encoding" do
      it "should not escape text messages" do
        within("#new-text-message") do
          fill_in "Message", with: "A & B"
          click_on "Post Message"
        end

        open_email(current_user.email)
        expect(current_email).to have_body_text("A & B")
      end

      it "should not escape link messages" do
        within("#new-link-message") do
          fill_in "Web address", with: "example.com?foo&bar"
          fill_in "Title", with: "An example URL with & symbols"
          fill_in "Description", with: "Some words & some more words"
          click_on "Add Link"
        end
        open_email(current_user.email)
        expect(current_email).to have_body_text("http://example.com?foo&bar")
        expect(current_email).to have_body_text("An example URL with & symbols")
        expect(current_email).to have_body_text("Some words & some more words")
      end

      it "should not escape deadline messages" do
        within("#new-deadline-message") do
          fill_in "Deadline", with: "Wednesday, 07 December 2011" # format the date picker returns
          fill_in "Title", with: "Planning application deadline & so on"
          click_on I18n.t("message.deadlines.new.submit")
        end
        open_email(current_user.email)
        expect(current_email).to have_body_text("Planning application deadline & so on")
      end
    end
  end

  context "privacy" do
    context "public threads" do
      include_context "signed in as a site user"

      before do
        current_user.prefs.update_column(:email_status_id, 1)
        visit thread_path(thread)
        subscribe_button.click
      end

      it "should state that the thread is public" do
        within("#new-text-message") do
          fill_in "Message", with: "Notification test"
          click_on "Post Message"
        end

        open_email(current_user.email)
        expect(current_email).to have_body_text("Everyone can view")
      end
    end

    context "private threads" do
      include_context "signed in as a group member"

      let(:thread) { create(:message_thread_with_messages, :private, group: current_group) }

      before do
        current_user.prefs.update_column(:email_status_id, 1)
        visit thread_path(thread)
        subscribe_button.click
      end

      it "should state that the thread is private" do
        within("#new-text-message") do
          fill_in "Message", with: "Notification test"
          click_on "Post Message"
        end

        open_email(current_user.email)
        expect(current_email).to have_body_text("Only members of")
      end
    end

    context "committee threads" do
      include_context "signed in as a committee member"

      let(:thread) { create(:message_thread_with_messages, :committee, group: current_group) }

      before do
        current_user.prefs.update_column(:email_status_id, 1)
        visit thread_path(thread)
        subscribe_button.click
      end

      it "should state that the thread is private" do
        within("#new-text-message") do
          fill_in "Message", with: "Notification test"
          click_on "Post Message"
        end

        open_email(current_user.email)
        expect(current_email).to have_body_text("Only committee members of")
      end
    end
  end
end
