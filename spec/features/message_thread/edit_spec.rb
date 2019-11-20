# frozen_string_literal: true

require "spec_helper"

describe "Thread" do
  let(:thread) { create(:message_thread_with_messages, group: group, created_by: creator) }
  let(:group) { create(:group, default_thread_privacy: "group")}
  let(:creator) { create(:group_membership, :committee, group: group).user }

  context "as site user" do
    include_context "signed in as a site user"

    before do
      visit edit_thread_path(thread)
    end

    it "is unautharized" do
      expect(page.status_code).to eq 401
    end
  end

  context "as committee user" do
    include_context "signed in as a site user"
    let(:password) { "password" }
    let(:current_user) { create(:user, password: password, password_confirmation: password) }
    let!(:group_member) { create :group }

    before do
      create :group
      create(:group_membership, :committee, group: group, user: current_user)
      create(:group_membership, group: group_member, user: current_user)
      visit edit_thread_path(thread)
    end

    it "can only change the thread to groups user has membership" do
      expect(page).to have_select("Owned by", with_options: [group.name, group_member.name])
    end
  end
end
