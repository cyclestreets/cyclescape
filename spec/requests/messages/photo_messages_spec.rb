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
    end
  end
end
