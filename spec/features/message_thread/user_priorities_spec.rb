# frozen_string_literal: true

require "spec_helper"

describe "user favourites", js: true do
  include_context "signed in as a site user"
  let(:thread) { create(:message_thread_with_messages) }

  it "allows changing favourites" do
    visit thread_path(thread)
    find(".far.fa-star").click

    # Wait for the star to change to filled (gold), indicating the favourite was saved
    expect(page).to have_css(".fas.fa-star")

    find(".fas.fa-star").click

    # Wait for the star to change back to empty, indicating the favourite was removed
    expect(page).to have_css(".far.fa-star")
  end
end
