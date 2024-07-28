# frozen_string_literal: true

require "spec_helper"

RSpec.describe ApplicationPolicy do
  describe "#application_view_full_name?" do
    subject(:view_full_name) { described_class.new(current_user, nil).application_view_full_name?(user_being_viewed) }

    let(:current_user) { build_stubbed :user }
    let(:user_being_viewed) { build_stubbed(:user_profile, visibility: "group").user }

    it "blocks viewing" do
      expect(view_full_name).to eq false
    end

    context "when current_user is admin" do
      let(:current_user) { build_stubbed :user, :admin }

      it "allows viewing" do
        expect(view_full_name).to eq true
      end
    end

    context "when current_user is in a group" do
      let(:user_being_viewed) { create(:user_profile, visibility: "group").user }
      let(:membership) { create :group_membership }
      let(:current_user) { membership.user }
      let(:group) { membership.group }

      context "that is shared" do
        before do
          create :group_membership, user: user_being_viewed, group: group
        end

        it "allows viewing" do
          expect(view_full_name).to eq true
        end
      end

      context "that is not shared" do
        before do
          create :group_membership, user: user_being_viewed
        end

        it "blocks viewing" do
          expect(view_full_name).to eq false
        end
      end
    end

    context "when current_user is in a committee" do
      let(:membership) { create :group_membership, :committee }
      let(:current_user) { membership.user }
      let(:user_being_viewed) { create(:user_profile, visibility: "group").user }
      let(:group) { membership.group }

      context "when other user is requesting to join group" do
        before do
          create :group_membership_request, user: user_being_viewed, group: group
        end

        it "allows viewing" do
          expect(view_full_name).to eq true
        end
      end

      context "when other user is requesting to join different group" do
        before do
          create :group_membership_request, user: user_being_viewed
        end

        it "blocks viewing" do
          expect(view_full_name).to eq false
        end
      end
    end
  end
end
