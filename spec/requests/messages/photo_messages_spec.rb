require "spec_helper"

describe "Photo messages" do
  let(:thread) { FactoryGirl.create(:message_thread) }

  def photo_form
    within(".new-photo-message") { yield }
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
        fill_in "Message", with: "Here's some nice photos I took."
        click_on "Create Photo message"
      end
      page.should have_content("Here's some nice photos I took.")
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
      page.should have_css(dom_id_selector(photo_message))
    end

    it "should have a caption" do
      within("figcaption") do
        page.should have_content(photo_message.caption)
      end
    end

    it "should use the caption as the alt tag" do
      page.should have_xpath("//img[@alt='#{photo_message.caption}']")
    end
  end
end
