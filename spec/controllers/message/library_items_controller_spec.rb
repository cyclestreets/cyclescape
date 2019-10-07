# frozen_string_literal: true

require "spec_helper"

describe Message::LibraryItemsController do
  context "as a site user" do
    let(:user) { create(:user) }
    let(:thread) { create(:message_thread) }
    let(:library_item) { create(:library_item) }
    let(:last_added) { LibraryItemMessage.last }
    let(:message_body) { "this is a useful item" }

    before do
      sign_in user
    end

    let!(:akismet_req) do
      stub_request(:post, %r{rest\.akismet\.com/1\.1/comment-check})
        .with(body: { blog: "http://www.cyclescape.org/",
                      comment_author: user.full_name,
                      comment_author_email: user.email,
                      comment_content: message_body,
                      comment_type: "comment",
                      is_test: "1" }).to_return(status: 200, body: "false")
    end

    it "should create a library item message" do
      post :create, params: { library_item_message: { library_item_id: library_item.id }, message: { body: message_body }, thread_id: thread.id }
      expect(response.status).to be(302)
      expect(last_added.library_item_id).to eq(library_item.id)
      expect(last_added.message.body).to eq(message_body)
    end
  end
end
