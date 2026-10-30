# frozen_string_literal: true

require "spec_helper"

describe "links inside turbo frames", js: true do
  include_context "signed in as a site user"
  let(:issue) { create(:issue) }
  let!(:thread) { create(:message_thread_with_messages, issue: issue) }

  it "opens the issue from the threads list" do
    visit threads_path(view: "all")
    within("turbo-frame#threads_frame") { click_link(issue.title) }

    expect(page).to have_current_path(issue_path(issue))
  end

  it "opens a message author's profile from the thread" do
    author = thread.messages.first.created_by
    visit thread_path(thread)
    within("turbo-frame#messages") { click_link(author.name, match: :first) }

    expect(page).to have_current_path(user_profile_path(author))
  end
end
