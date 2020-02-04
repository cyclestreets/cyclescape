# frozen_string_literal: true

require "spec_helper"

describe LibrariesController, type: :controller do
  let(:thread) { create(:message_thread) }
  let!(:body_thread) { create :library_note, title: "blank", body: "There is mention of a thread" }
  let(:tag_issue) { create :library_document, title: "blank" }

  before do
    tag_issue.update!(tags_string: "issue,othertag")
  end

  describe "#relevant", solr: true do
    context "for threads without an issue or tags" do
      it "does not error" do
        expect { get :relevant, params: { thread_id: thread.id, format: :json } }
          .not_to raise_error
        expect(response.status).to eq 200
      end
    end

    context "for threads with tags but no issue" do
      before do
        thread.update!(tags_string: "thread")
      end

      it "returns something" do
        get :relevant, params: { thread_id: thread.id, format: :json }
        expect(json_response.map { |li| li["id"] } ).to eq [body_thread.library_item_id]
      end
    end

    context "for threads and issue with tags" do
      before do
        thread.update!(tags_string: "thread", issue: create(:issue, tags_string: "issue"))
      end

      it "returns something" do
        get :relevant, params: { thread_id: thread.id, format: :json }
        expect(json_response.map { |li| li["id"] }).to eq [tag_issue.library_item_id, body_thread.library_item_id]
      end
    end
  end
end
