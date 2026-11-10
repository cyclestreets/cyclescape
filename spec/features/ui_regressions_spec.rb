# frozen_string_literal: true

require "spec_helper"

describe "new UI regressions", js: true do
  include_context "signed in as a site user"
  let!(:thread) { create(:message_thread_with_messages) }

  it "replaces the vote frame and shows the vote after reloading" do
    message = thread.messages.first
    visit thread_path(thread)
    within("#message_#{message.id}") { find("button.like").click }
    expect(page).to have_css("#message_#{message.id} button.liked")
    expect(page).to have_css("turbo-frame#votable_message_#{message.id}", count: 1)
    visit thread_path(thread)
    expect(page).to have_css("#message_#{message.id} button.liked", text: "1")
    within("#message_#{message.id}") { find("button.like").click }
    expect(page).to have_no_css("#message_#{message.id} button.liked")
    visit thread_path(thread)
    expect(page).to have_no_css("#message_#{message.id} button.liked")
  end
end

describe "message moderation popovers", js: true do
  include_context "signed in as admin"

  it "shows the message body as text" do
    thread = create(:message_thread)
    create(:message, :possible_spam, thread: thread, body: %(<img src=x onerror="window.pwned=1">))
    visit admin_message_moderations_path
    find("td[data-bs-content]").hover
    expect(page).to have_css(".popover", text: "<img")
    expect(page.evaluate_script("window.pwned")).to be_nil
  end
end

describe "pages with previously missing translations" do
  include_context "signed in as a site user"

  it "shows planning applications guidance when the user has no locations" do
    visit planning_applications_path
    expect(page).to have_link(I18n.t("planning_applications.index.add_some_locations"))
  end

  it "shows the empty groups directory" do
    visit groups_path(page: 999)
    expect(page).to have_content(I18n.t("groups.index.no_results_found"))
  end
end

describe "popovers with user supplied names", js: true do
  include_context "signed in as a site user"
  let(:evil_name) { %(<img src=x onerror="window.pwned=1">) }

  it "does not run html from a voter's name" do
    thread = create(:message_thread_with_messages)
    message = thread.messages.first
    create(:user, full_name: evil_name, display_name: evil_name).vote_for(message)
    visit thread_path(thread)
    find("#message_#{message.id} button.like").hover
    expect(page).to have_css(".popover")
    expect(page.evaluate_script("window.pwned")).to be_nil
  end
end
