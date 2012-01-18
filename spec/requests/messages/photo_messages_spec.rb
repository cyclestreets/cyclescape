require "spec_helper"

describe "Photo messages" do
  let(:thread) { FactoryGirl.create(:message_thread) }

  def photo_form
    within("#new-photo-message") { yield }
  end

  context "new" do
    include_context "signed in as a site user"

    before do
      visit thread_path(thread)
    end

    it "should post a photo message" do
      photo_form do
        attach_file("Photo", abstract_image_path)
        fill_in "Caption", with: "An abstract image"
        click_on "Add Photo"
      end
      page.should have_css(".photo img")
      within('figcaption') do
        page.should have_content("An abstract image")
      end
    end
  end

  context "show" do
    let(:message) { FactoryGirl.create(:message, thread: thread) }
    let!(:photo_message) { FactoryGirl.create(:photo_message, message: message, created_by: FactoryGirl.create(:user)) }

    before do
      visit thread_path(thread)
    end

    it "should display the photo" do
      photo_message.should be_valid
      # Ugh, inconsistent naming!
      page.should have_css("#photo_message_#{photo_message.id}")
    end

    it "should have a caption" do
      within("figcaption") do
        page.should have_content(photo_message.caption)
      end
    end

    it "should have the caption as part of the alt tag" do
      page.should have_xpath("//img/@alt[contains(., '#{photo_message.caption}')]")
    end

    context "the photo" do
      it "should link to a larger version" do
        page.should have_xpath("//a[@rel='#overlay' and @href='#{thread_photo_path(thread, photo_message)}']/img")
      end

      it "should display a larger version when clicked" do
        # Reload the photo for the URL because the factory-created instance has
        # the filename as additional information that we actually discard but is
        # used in the URL generation if found.
        photo_path = PhotoMessage.find(photo_message.id).photo_medium.url
        find(:xpath, "//a[@href='#{thread_photo_path(thread, photo_message)}']").click
        page.should have_xpath("//img[@src='#{photo_path}']")
      end
    end
  end
end
