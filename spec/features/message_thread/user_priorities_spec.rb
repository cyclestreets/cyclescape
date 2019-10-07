# frozen_string_literal: true

require "spec_helper"

describe "user priorities", js: true do
  include_context "signed in as a site user"
  let(:thread) { create(:message_thread_with_messages) }

  it "allows changing priorities" do
    visit thread_path(thread)
    within(".priority-panel") do
      choose I18n.t("thread_priorities.medium")
    end
    expect(page).to have_content(I18n.t("message_thread.user_priorities.update.success"))
  end
end
