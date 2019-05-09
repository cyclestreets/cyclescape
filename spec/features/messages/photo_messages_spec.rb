# frozen_string_literal: true

require "spec_helper"

describe "Photo messages" do
  let(:thread) { create(:message_thread) }

  def photo_form
    within("#new-photo-message") { yield }
  end

  context "new" do
    include_context "signed in as a site user"

    before do
      visit thread_path(thread)
    end

    # Sadly phantomjs has a problem with data src's
    # and they seem to trigger the onerror instead of the onload
    # when added to the DOM.  This causes croppy to not load properly.
    xit "should post a photo message", js: true do
      thread.created_by.prefs.update_column(:email_status_id, 1)
      click_on "Photo"
      photo_form do
        attach_file("Photo", abstract_image_path)
        fill_in "Caption", with: "An abstract image"
        click_on "Add Photo"
      end
      expect(page).to have_css(".photo img")
      within("figcaption") do
        expect(page).to have_content("An abstract image")
      end

      open_email(thread.created_by.email)
      expect(current_email).to have_body_text("An abstract image")
    end
  end

  context "show" do
    let(:message) { create(:message, thread: thread) }
    let!(:photo_message) { create(:photo_message, message: message, created_by: create(:user)) }

    before do
      visit thread_path(thread)
    end

    it "should display the photo" do
      expect(photo_message).to be_valid
      # Ugh, inconsistent naming!
      expect(page).to have_css("#photo_message_#{photo_message.id}")
    end

    it "should have a caption" do
      within("figcaption") do
        expect(page).to have_content(photo_message.caption)
      end
    end

    it "should have the caption as part of the alt tag" do
      expect(page).to have_xpath("//img/@alt[contains(., '#{photo_message.caption}')]")
    end

    context "the photo" do
      it "should link to a larger version" do
        expect(page).to have_xpath("//a[@rel='#overlay' and @href='#{thread_photo_path(thread, photo_message)}']/img")
      end

      it "should display a larger version when clicked" do
        # Reload the photo for the URL because the factory-created instance has
        # the filename as additional information that we actually discard but is
        # used in the URL generation if found.
        photo_path = PhotoMessage.find(photo_message.id).photo_medium.url
        find(:xpath, "//a[@href='#{thread_photo_path(thread, photo_message)}']").click
        expect(page).to have_xpath("//img[@src='#{photo_path}']")
      end
    end
  end
end
