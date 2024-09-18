# frozen_string_literal: true

require "spec_helper"

RSpec.describe MessageThreadPolicy do
  subject { described_class.new(user, thread) }
  let(:all_actions) { %i[new create show edit update destroy close vote_detail edit_all_fields] }
  let(:forbiden_actions) { all_actions - allowed_actions }

  context "being an admin" do
    let(:allowed_actions) { all_actions }
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
      let(:allowed_actions) { %i[new create show edit update destroy vote_detail edit_all_fields] }
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
      let(:forbiden_actions) { all_actions }

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
      let(:group) { membership.group }

      context "committee thread" do
        let(:other_user) { create :user }
        let(:privacy) { MessageThread::COMMITTEE }
        let(:forbiden_actions) { all_actions }

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

        context "when you are subscribed" do
          before do
            thread.add_subscriber user
          end

          let(:allowed_actions) { %i[new create show vote_detail close] }

          it do
            expect(subject).to permit_actions(allowed_actions)
            expect(subject).to forbid_actions(forbiden_actions)
          end
        end
      end
    end

    context "with a thread in another group" do
      let(:group) { create :group }

      context "private to group thread" do
        let(:privacy) { MessageThread::GROUP }
        let(:forbiden_actions) { all_actions }

        it do
          expect(subject).to forbid_actions(forbiden_actions)
        end
      end

      context "public thread in group" do
        let(:privacy) { MessageThread::PUBLIC }
        let(:allowed_actions) { %i[show vote_detail] }

        it do
          expect(subject).to permit_actions(allowed_actions)
          expect(subject).to forbid_actions(forbiden_actions)
        end

        context "when you are subscribed" do
          before do
            thread.add_subscriber user
          end

          let(:allowed_actions) { %i[show vote_detail close] }

          it do
            expect(subject).to permit_actions(allowed_actions)
            expect(subject).to forbid_actions(forbiden_actions)
          end
        end
      end
    end
  end

  context "with a non logged in user" do
    let(:user) { nil }
    context "new thread" do
      let(:thread) { build :message_thread }
      let(:allowed_actions) { %i[show edit_all_fields] }

      it do
        expect(subject).to permit_actions(allowed_actions)
        expect(subject).to forbid_actions(forbiden_actions)
      end
    end

    context "persisted thread" do
      let(:thread) { create :message_thread }
      let(:allowed_actions) { %i[show] }

      it do
        expect(subject).to permit_actions(allowed_actions)
        expect(subject).to forbid_actions(forbiden_actions)
      end
    end
  end

  context "private thread (direct messages)" do
    let(:thread) { create :message_thread, created_by: creating_user, user: recieving_user, privacy: MessageThread::PRIVATE  }

    context "both users have public profiles" do
      let(:creating_user) { create :user }
      let(:recieving_user) { create :user }

      context "when current_user created the thread" do
        let(:user) { creating_user }
        let(:allowed_actions) { %i[show edit update close vote_detail] }
        let(:forbiden_actions) { %i[new create] } # need to share a group etc. to start a thread

        it do
          expect(subject).to permit_actions(allowed_actions)
          expect(subject).to forbid_actions(forbiden_actions)
        end
      end

      context "when current_user is recieving thread" do
        let(:user) { recieving_user }
        let(:allowed_actions) { %i[show close vote_detail] }

        it do
          expect(subject).to permit_actions(allowed_actions)
          expect(subject).to forbid_actions(forbiden_actions)
        end
      end

      context "when current user is not involved in thread" do
        let(:membership) { create :group_membership, :committee }
        let(:group) { membership.group }
        let(:user) { membership.user }
        let(:allowed_actions) { %i[new create] }

        before do
          create :group_membership, user: creating_user, group: group
          create :group_membership, user: recieving_user, group: group
        end

        it do
          expect(subject).to permit_actions(allowed_actions)
        end
      end

      describe "user blocks" do
        let(:user) { creating_user }
        let(:other_user) { ([creating_user, recieving_user] - [user]).first }
        let(:allowed_actions) { %i[show vote_detail close edit update] }

        context "current user has blocked other user" do
          before { user.user_blocks.create!(blocked: other_user) }

          it do
            expect(subject).to permit_actions(allowed_actions)
            expect(subject).to forbid_actions(forbiden_actions)
          end
        end

        context "other user has blocked current user" do
          before { other_user.user_blocks.create!(blocked: user) }

          it do
            expect(subject).to permit_actions(allowed_actions)
            expect(subject).to forbid_actions(forbiden_actions)
          end
        end
      end
    end

    context "have private profile" do
      let(:creating_user) { create :user }
      let(:recieving_user) { create(:user_profile, visibility: "group").user }
      let(:user) { creating_user }

      context "when the users share a group" do
        before do
          membership = create :group_membership, user: creating_user
          create :group_membership, user: recieving_user, group: membership.group
        end

        let(:allowed_actions) { %i[new edit update create show vote_detail close] }

        it do
          expect(subject).to permit_actions(allowed_actions)
          expect(subject).to forbid_actions(forbiden_actions)
        end
      end

      context "when current_user is in a committee" do
        context "when other user is requesting to join group" do
          before do
            membership = create :group_membership_request, user: recieving_user
            create :group_membership, :committee, user: creating_user, group: membership.group
          end

          let(:allowed_actions) { %i[new create edit update show vote_detail close] }

          it do
            expect(subject).to permit_actions(allowed_actions)
            expect(subject).to forbid_actions(forbiden_actions)
          end
        end

        context "when other user is in no overlapping group" do
          before do
            create :group_membership, :committee, user: creating_user
            create :group_membership, :committee, user: recieving_user
          end

          let(:allowed_actions) { %i[edit update show vote_detail close] }

          it do
            expect(subject).to permit_actions(allowed_actions)
            expect(subject).to forbid_actions(forbiden_actions)
          end
        end
      end
    end
  end
end
