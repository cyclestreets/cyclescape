# frozen_string_literal: true

require "spec_helper"

describe Message::LibraryItemsController do
  context "as a site user" do
    let(:user) { create(:user) }
    let(:thread) { create(:message_thread) }
    let(:library_item) { create(:library_item) }
    let(:last_added) { LibraryItemMessage.last }

    before do
      sign_in user
    end

    it "should create a library item message" do
      post :create, params: { library_item_message: { library_item_id: library_item.id }, message: { body: "this is a useful item" }, thread_id: thread.id }
      expect(response.status).to be(302)
      expect(last_added.library_item_id).to eq(library_item.id)
      expect(last_added.message.body).to eq("this is a useful item")
    end
  end
end
