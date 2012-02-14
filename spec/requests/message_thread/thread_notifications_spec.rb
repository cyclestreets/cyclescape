require "spec_helper"

describe "thread notifications" do
  let(:thread) { FactoryGirl.create(:message_thread) }
  let(:subscribe_button) { find_button(I18n.t("formtastic.actions.thread_subscription.create")) }

  context "new messages" do
    include_context "signed in as a site user"

    before do
      current_user.prefs.notify_subscribed_threads!
      visit thread_path(thread)
      subscribe_button.click
    end

    it "should send an email for a new text message" do
      within("#new-text-message") do
        fill_in "Message", with: "Notification test"
        click_on "Post Message"
      end
      open_email(current_user.email, with_subject: /^Re/)
      current_email.should have_subject("Re: #{thread.title}")
      current_email.should have_body_text(/Notification test/)
      current_email.should have_body_text(current_user.name)
      current_email.should be_delivered_from("#{current_user.name} <notifications@cyclescape.org>")
      current_email.should have_reply_to("Cyclescape <thread-#{thread.public_token}@cyclescape.org>")
    end

    it "should send an email for a link message" do
      within("#new-link-message") do
        fill_in "URL", with: "example.com"
        fill_in "Title", with: "An example URL"
        fill_in "Description", with: "Some words"
        click_on "Add Link"
      end
      open_email(current_user.email)
      current_email.should have_body_text("http://example.com")
      current_email.should have_body_text("An example URL")
      current_email.should have_body_text("Some words")
    end

    it "should send an email for a library item message"
#     library_note = FactoryGirl.create(:library_note)
#     visit thread_path(thread) # to update the select field

#     within("#new-library-item-message") do
#       select library_note.title, from: "Item"
#       fill_in "Message", with: "Some words"
#       click_on "Add Library Item"
#     end
#     open_email(current_user.email)
#     current_email.should have_body_text(library_note.title)
#     current_email.should have_body_text("#{polymorphic_url library_note}")
#     current_email.should have_body_text("Some words")
#   end

    it "should send an email for a deadline message" do
      within("#new-deadline-message") do
        fill_in "Deadline", with: "Wednesday, 07 December 2011" # format the date picker returns
        fill_in "Title", with: "Planning application deadline"
        click_on "Add Deadline"
      end
      open_email(current_user.email)
      current_email.should have_body_text("Planning application deadline")
      current_email.should have_body_text("07 December 2011") # format used in display
    end

    it "should send an email for a photo message" do
      within("#new-photo-message") do
        attach_file "Photo", abstract_image_path
        fill_in "Caption", with: "Some words"
        click_on "Add Photo"
      end

      open_email(current_user.email)
      current_email.should have_body_text("Some words")
      # The URL will actually link to a particular message_id anchor, but we don't know
      # what that will be to test it.
      pending "Figure out testing the url"
    end

    context "html encoding" do
      it "should not escape text messages" do
        within("#new-text-message") do
          fill_in "Message", with: "A & B"
          click_on "Post Message"
        end

        open_email(current_user.email)
        current_email.should have_body_text("A & B")
      end

      it "should not escape link messages" do
        within("#new-link-message") do
          fill_in "URL", with: "example.com?foo&bar"
          fill_in "Title", with: "An example URL with & symbols"
          fill_in "Description", with: "Some words & some more words"
          click_on "Add Link"
        end
        open_email(current_user.email)
        current_email.should have_body_text("http://example.com?foo&bar")
        current_email.should have_body_text("An example URL with & symbols")
        current_email.should have_body_text("Some words & some more words")
      end

      it "should not escape deadline messages" do
        within("#new-deadline-message") do
          fill_in "Deadline", with: "Wednesday, 07 December 2011" # format the date picker returns
          fill_in "Title", with: "Planning application deadline & so on"
          click_on "Add Deadline"
        end
        open_email(current_user.email)
        current_email.should have_body_text("Planning application deadline & so on")
      end

      it "should not escape photo messages" do
        within("#new-photo-message") do
          attach_file "Photo", abstract_image_path
          fill_in "Caption", with: "Some words & some more words"
          click_on "Add Photo"
        end

        open_email(current_user.email)
        current_email.should have_body_text("Some words & some more words")
      end
    end
  end
end
