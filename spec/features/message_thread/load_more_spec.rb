# frozen_string_literal: true

require "spec_helper"

describe "loading earlier messages", js: true do
  include_context "signed in as a site user"

  let(:thread) { create(:message_thread) }
  let!(:messages) do
    Array.new(15) { |i| create(:message, thread: thread, created_at: (20 - i).days.ago) }
  end

  before do
    create(:thread_view, thread: thread, user: current_user, viewed_at: 1.day.ago)
    create(:message, thread: thread, created_at: 1.hour.ago)
  end

  it "adds the earlier messages above the loaded ones, once each" do
    visit thread_path(thread)
    expect(page).to have_no_css("#message_#{messages.first.id}")

    click_on I18n.t("shared.load_more")

    expect(page).to have_css("#message_#{messages.first.id}")
    expect(page).to have_no_link(I18n.t("shared.load_more"))
    expect(page).to have_css("#messages > li", count: thread.messages.count)
    expect(page).to have_current_path(thread_path(thread))
  end
end
