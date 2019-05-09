# frozen_string_literal: true

require "spec_helper"

# This is a very thin test, since most of the functionality is tested
# in the controller test. Here we just want to make sure that the CSS
# class appears, for the UJS magic to kick in.

describe "thread views" do
  context "for a signed in user" do
    include_context "signed in as a site user"
    let(:thread) { create(:message_thread_with_messages) }
    let!(:thread_view) { create(:thread_view, thread: thread, user: current_user) }

    it "should output a page with the correct class" do
      visit thread_path(thread)
      expect(page).to have_css("article.message.thread-view-from-here")
    end
  end
end
