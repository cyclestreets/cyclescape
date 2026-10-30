# frozen_string_literal: true

require "spec_helper"

describe "threads view switcher", js: true do
  include_context "signed in as a site user"

  def expect_frame_view(view)
    expect(page).to have_css("turbo-frame#threads_frame[src*='view=#{view}']")
  end

  def wait_for_switcher
    expect(page).to have_css("form[data-controller=threads] .selection[style*=translateX]")
  end

  def save_view(view)
    page.driver.browser.manage.add_cookie(name: "cyclescape-message-threads", value: view)
  end

  it "reloads the frame when switching back to the view in the URL" do
    visit threads_path(view: "all")
    choose("view_mine", allow_label_click: true)
    expect_frame_view("mine")

    choose("view_all", allow_label_click: true)
    expect_frame_view("all")
  end

  it "updates the URL and drops the page when switching view" do
    visit threads_path(view: "all", page: 99)
    choose("view_mine", allow_label_click: true)

    expect(page).to have_current_path(threads_path(view: "mine"))
  end

  it "does not reload the frame when the saved view is already shown" do
    visit threads_path
    save_view("mine")
    visit threads_path

    wait_for_switcher
    expect(page).to have_no_css("turbo-frame#threads_frame[src]")
  end

  it "prefers the view in the URL over the saved view" do
    visit threads_path
    save_view("favourites")
    visit threads_path(view: "all")

    wait_for_switcher
    expect(page).to have_checked_field("view_all", visible: :all)
    expect(page).to have_no_css("turbo-frame#threads_frame[src]")
  end

  it "restores the saved view when the URL has none" do
    visit threads_path
    save_view("all")
    visit threads_path

    expect(page).to have_checked_field("view_all", visible: :all)
    expect_frame_view("all")
  end

  it "updates the URL when paginating" do
    create_list(:message_thread_with_messages, Kaminari.config.default_per_page + 1)
    visit threads_path(view: "all")
    within("turbo-frame#threads_frame", match: :first) { click_link("Next", match: :first) }

    expect(page).to have_current_path(threads_path(view: "all", page: 2))
  end
end
