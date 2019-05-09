# frozen_string_literal: true

require "spec_helper"

describe "Subscriptions", type: :feature do
  let(:thread) { create(:message_thread) }
  let(:subscription) { create(:thread_subscription, thread: thread) }
  let(:other_sub) { create(:thread_subscription, thread: thread) }
  let(:sub_user) { subscription.user }

  it "should let the subscription user's public token unsubscribe" do
    visit edit_thread_subscription_path(thread, subscription, t: sub_user.public_token)
    expect(page).to have_content(thread.title)
    click_on t("formtastic.actions.thread_subscription.delete")
    expect(page).to have_content(t("message_thread.subscriptions.destroy.success"))
  end

  it "should not let other user's public token unsubscribe" do
    visit edit_thread_subscription_path(thread, subscription, t: other_sub.user.public_token)
    expect(page).to have_content(t("application.permission_denied"))
  end
end
