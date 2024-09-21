# frozen_string_literal: true

require "spec_helper"

describe "Message threads", type: :feature do
  let!(:user_being_messaged) { create(:user_profile, visibility: "group").user }

  context "as a site user" do
    include_context "signed in as a site user"

    before do
      membership = create :group_membership, user: current_user
      create :group_membership, user: user_being_messaged, group: membership.group
    end

    it "should be able to send a private message" do
      visit user_profile_path(user_being_messaged)
      click_link "Send private message"
      expect(page).to have_content("Send a private message to #{user_being_messaged.full_name}")
      fill_in "Discussion title", with: "Why hello"
      fill_in "Message", with: "Testing a new message!", match: :first
      click_on "Send Private message"
      expect(page).to have_content("Private Message between")
      expect(page).to have_content("Why hello")
    end
  end
end
