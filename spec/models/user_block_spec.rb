# frozen_string_literal: true


require "spec_helper"

RSpec.describe UserBlock, type: :model do
  let(:current_user) { create :user }
  let(:other_user) { create :user }

  context "current_user has blocked other_user" do
    before do
      current_user.user_blocks.create!(blocked: other_user)
    end

    xit "neither user can message the other" do
      expect(Authorization::Engine.instance.permit?(:send_private_message, object: other_user, user: current_user)).to eq(false)
      expect(Authorization::Engine.instance.permit?(:send_private_message, object: current_user, user: other_user)).to eq(false)
    end
  end
end
