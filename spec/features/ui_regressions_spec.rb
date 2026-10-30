# frozen_string_literal: true

require "spec_helper"

describe "new UI regressions", js: true do
  include_context "signed in as a site user"
  let!(:thread) { create(:message_thread_with_messages) }

  it "enables popovers on content loaded into a frame" do
    current_user.thread_subscriptions.create!(thread: thread)
    visit threads_path(view: "mine")
    find("#favourite_message_thread_#{thread.id} i").hover
    expect(page).to have_css(".popover", count: 1)
    choose("view_all", allow_label_click: true)
    expect(page).to have_css("turbo-frame#threads_frame[src*='view=all']")
    sleep 1
    find("#content h1", match: :first).hover
    find("#favourite_message_thread_#{thread.id} i").hover
    expect(page).to have_css(".popover", count: 1)
  end

  it "does not duplicate popovers after a turbo stream render" do
    other = create(:message_thread_with_messages)
    visit threads_path(view: "all")
    find("#favourite_message_thread_#{other.id} a").click
    expect(page).to have_css("#favourite_message_thread_#{other.id} .fas.fa-star")
    find("#favourite_message_thread_#{thread.id} i").hover
    sleep 0.5
    expect(page).to have_css(".popover", count: 1)
  end

  it "replaces the vote frame and shows the vote after reloading" do
    message = thread.messages.first
    visit thread_path(thread)
    within("#message_#{message.id}") { find("button.like").click }
    expect(page).to have_css("#message_#{message.id} button.liked")
    expect(page.evaluate_script("document.querySelectorAll('turbo-frame#votable_message_#{message.id}').length")).to eq(1)
    visit thread_path(thread)
    expect(page).to have_css("#message_#{message.id} button.liked", text: "1")
    within("#message_#{message.id}") { find("button.like").click }
    expect(page).to have_no_css("#message_#{message.id} button.liked")
    visit thread_path(thread)
    expect(page).to have_no_css("#message_#{message.id} button.liked")
  end

  it "shows the subscribe flash once and lets it be dismissed" do
    visit threads_path(view: "all")
    within("#subscription_message_thread_#{thread.id}") { click_on I18n.t("helpers.submit.thread_subscription.create") }
    expect(page).to have_css("#flash .alert")
    find("#flash .alert button").click
    expect(page).to have_no_css("#flash .alert")
    visit tags_path
    expect(page).to have_no_css("#flash .alert")
  end

  it "shows the last known private message count straight away" do
    page.driver.browser.manage.add_cookie(name: "unviewed_private_count", value: "3")
    visit tags_path
    expect(page).to have_css(".private-message-counter", text: "3", wait: 2)
  end

  it "opens and closes the search box" do
    visit tags_path
    find("#search i").click
    expect(page).to have_css("#search.expanded")
    find("#search input").click
    expect(page).to have_css("#search.expanded")
    find("#search input").send_keys(:escape)
    expect(page).to have_no_css("#search.expanded")
    find("#search i").click
    expect(page).to have_css("#search.expanded")
    find("#content h1", match: :first).click
    expect(page).to have_no_css("#search.expanded")
    find("#search i").click
    fill_in "query", with: "foo\n"
    expect(page).to have_current_path(/query=foo/)
  end
end

describe "group request form", js: true do
  include_context "signed in as a site user"
  it "shows the group request web address" do
    visit new_group_request_path
    expect(page).to have_field("group_request_webname", disabled: true, with: /\A\./)
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
