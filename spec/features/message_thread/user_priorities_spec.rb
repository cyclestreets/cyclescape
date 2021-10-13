# frozen_string_literal: true

require "spec_helper"

describe "user favourites", js: true do
  include_context "signed in as a site user"
  let(:thread) { create(:message_thread_with_messages) }

  it "allows changing favourites" do
    visit thread_path(thread)
    find(".fa-star-o").click

    expect(page).to have_content(I18n.t("message_thread.user_favourites.create.success"))

    find(".fa-star").click

    expect(page).to have_content(I18n.t("message_thread.user_favourites.destroy.success"))
  end
end
