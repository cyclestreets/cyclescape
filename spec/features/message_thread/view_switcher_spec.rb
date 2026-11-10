# frozen_string_literal: true

require "spec_helper"

describe "threads view switcher", js: true do
  include_context "signed in as a site user"

  it "updates the URL and drops the page when switching view" do
    thread = create(:message_thread_with_messages)
    visit threads_path(view: "mine", page: 99)
    choose("view_all", allow_label_click: true)

    expect(page).to have_current_path(threads_path(view: "all"))
    expect(page).to have_content(thread.title)
  end

  it "updates the URL when paginating" do
    create_list(:message_thread_with_messages, Kaminari.config.default_per_page + 1)
    visit threads_path(view: "all")
    within("turbo-frame#threads_frame", match: :first) { click_link("Next", match: :first) }

    expect(page).to have_current_path(threads_path(view: "all", page: 2))
  end
end
