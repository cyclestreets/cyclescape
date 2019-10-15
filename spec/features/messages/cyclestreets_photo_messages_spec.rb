# frozen_string_literal: true

require "spec_helper"

describe "Cyclestreets Photo messages", type: :feature do
  let(:thread) { create(:message_thread) }

  describe "#show" do
    let(:message) { create(:message, thread: thread) }
    let!(:cs_photo_message) { create(:cyclestreets_photo_message, message: message, created_by: create(:user)) }

    before do
      visit thread_path(thread)
    end

    it "has the image" do
      within("figcaption") do
        expect(page).to have_content(cs_photo_message.caption)
      end
      cs_photo_path = CyclestreetsPhotoMessage.find(cs_photo_message.id).photo_preview.url
      expect(page).to have_xpath("//img[@src='#{cs_photo_path}']")
    end
  end
end
