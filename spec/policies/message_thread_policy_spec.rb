# frozen_string_literal: true

require "spec_helper"

RSpec.describe MessageThreadPolicy do
  subject { described_class.new(user, thread) }

  context "being an admin" do
    let(:allowed_actions) { %i[new create show edit update destroy close vote_detail] }
    let(:user) { build_stubbed :user, :admin }
    let(:thread) { build :message_thread }

    it "allows everything" do
      expect(subject).to permit_actions(allowed_actions)
    end
  end

  context "being in the group committee" do
    let(:membership) { create :group_membership, :committee }
    let(:user) { membership.user }
    let(:thread) { create :message_thread, group: group, privacy: privacy  }

    context "with a thread in your group" do
      let(:allowed_actions) { %i[new create show edit update destroy vote_detail] }
      let(:forbiden_actions) { %i[open close] }
      let(:group) { membership.group }

      context "committee thread" do
        let(:other_user) { create :user }
        let(:privacy) { MessageThread::COMMITTEE }

        it do
          expect(subject).to permit_actions(allowed_actions)
          expect(subject).to forbid_actions(forbiden_actions)
        end
      end

      context "private to group thread" do
        let(:privacy) { MessageThread::GROUP }

        it "allows everything" do
          expect(subject).to permit_actions(allowed_actions)
          expect(subject).to forbid_actions(forbiden_actions)
        end
      end
    end

    context "with a thread in another group" do
      let(:group) { create :group }
      let(:forbiden_actions) { %i[new create show edit update destroy vote_detail open close] }

      context "private to group thread" do
        let(:privacy) { MessageThread::GROUP }

        it "allows everything" do
          expect(subject).to forbid_actions(forbiden_actions)
        end
      end
    end
  end

  context "being a group member" do
    let(:membership) { create :group_membership }
    let(:user) { membership.user }
    let(:thread) { create :message_thread, group: group, privacy: privacy  }

    context "with a thread in your group" do
      let(:allowed_actions) { %i[new create show vote_detail] }
      let(:forbiden_actions) { %i[edit update destroy open close] }
      let(:group) { membership.group }

      context "committee thread" do
        let(:other_user) { create :user }
        let(:privacy) { MessageThread::COMMITTEE }
        let(:forbiden_actions) { %i[new create show edit update destroy vote_detail open close] }

        it do
          expect(subject).to forbid_actions(forbiden_actions)
        end
      end

      context "private to group thread" do
        let(:privacy) { MessageThread::GROUP }

        it do
          expect(subject).to permit_actions(allowed_actions)
          expect(subject).to forbid_actions(forbiden_actions)
        end
      end
    end

    context "with a thread in another group" do
      let(:group) { create :group }
      let(:forbiden_actions) { %i[new create show edit update destroy vote_detail open close] }

      context "private to group thread" do
        let(:privacy) { MessageThread::GROUP }

        it do
          expect(subject).to forbid_actions(forbiden_actions)
        end
      end
    end
  end
end
