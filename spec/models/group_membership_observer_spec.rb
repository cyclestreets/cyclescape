# frozen_string_literal: true

require "spec_helper"

describe GroupMembershipObserver do
  subject { GroupMembershipObserver.instance }

  context "basic checks" do
    let(:gm) { build(:group_membership) }

    it "should notice when GroupMembships are saved" do
      expect(subject).to receive(:after_save)

      GroupMembership.observers.enable :group_membership_observer do
        gm.save!
      end
    end
  end

  context "new committee members" do
    let(:thread) { create(:group_committee_message_thread) }
    let(:group_membership) { build(:group_membership, group: thread.group) }

    it "should subscribe user to committee threads if their preference is set" do
      user = group_membership.user
      user.prefs.update_column(:involve_my_groups, "subscribe")
      expect(thread.subscribers).not_to include(user)
      expect(thread.group.members).not_to include(user)
      expect(user.prefs.involve_my_groups_admin).to eq(false)
      GroupMembership.observers.enable :group_membership_observer do
        group_membership.role = "committee"
        group_membership.save
      end
      thread.reload
      expect(thread.subscribers).to include(user)
      expect(user.prefs.reload.involve_my_groups_admin).to eq(true)
    end

    it "should not subscribe them if they don't want subscribing" do
      user = group_membership.user
      user.prefs.update_column(:involve_my_groups, "notify")
      expect(thread.subscribers).not_to include(user)
      GroupMembership.observers.enable :group_membership_observer do
        group_membership.role = "committee"
        group_membership.save
      end
      thread.reload
      expect(thread.subscribers).not_to include(user)
    end
  end

  context "kicking out committee members" do
    let(:thread) { create(:group_committee_message_thread) }
    let(:group_membership) { create(:group_membership, group: thread.group, role: "committee") }

    it "should unsubscribe ex-committee members from committee only threads" do
      user = group_membership.user
      thread.add_subscriber(user)
      expect(thread.subscribers).to include(user)

      GroupMembership.observers.enable :group_membership_observer do
        group_membership.role = "member"
        group_membership.save
      end

      thread.reload
      expect(thread.subscribers).not_to include(user)
    end
  end

  context "joining group" do
    let(:thread) { create(:group_message_thread, :belongs_to_issue) }
    let(:group_membership) { build(:group_membership, group: thread.group) }
    let(:user) { group_membership.user }
    let(:private_thread) { create(:group_private_message_thread, :belongs_to_issue) }

    it "should subscribe the user to any group threads" do
      user.prefs.update_column(:involve_my_groups, "subscribe")
      expect(thread.subscribers).not_to include(user)
      GroupMembership.observers.enable :group_membership_observer do
        group_membership.save
      end
      thread.reload
      expect(thread.subscribers).to include(user)
    end

    it "should not subscribe normal members to committee threads" do
      user.prefs.update_column(:involve_my_groups, "subscribe")
      expect(private_thread.subscribers).not_to include(user)
      GroupMembership.observers.enable :group_membership_observer do
        group_membership.save
      end
      private_thread.reload
      expect(private_thread.subscribers).not_to include(user)
    end

    it "should not subscribe without the correct pref" do
      expect(thread.subscribers).not_to include(user)
      GroupMembership.observers.enable :group_membership_observer do
        group_membership.save
      end
      thread.reload
      expect(thread.subscribers).not_to include(user)
    end

    context "admin threads" do
      let(:thread) { create(:group_message_thread) }

      it "should subscribe to thread with pref set" do
        user.prefs.update_column(:involve_my_groups_admin, true)
        expect(thread.subscribers).not_to include(user)
        GroupMembership.observers.enable :group_membership_observer do
          group_membership.save
        end
        thread.reload
        expect(thread.subscribers).to include(user)
      end
    end
  end

  context "leaving group" do
    let(:group_membership) { create(:group_membership, group: thread.group) }
    let(:user) { group_membership.user }

    context "committee threads" do
      let(:thread) { create(:group_message_thread, :committee) }

      it "should unsubscribe you" do
        thread.add_subscriber(user)
        expect(thread.subscribers).to include(user)
        GroupMembership.observers.enable :group_membership_observer do
          group_membership.destroy
        end
        thread.reload
        expect(thread.subscribers).not_to include(user)
      end
    end

    context "private threads" do
      let(:thread) { create(:group_message_thread, :private) }

      it "should unsubscribe you" do
        thread.add_subscriber(user)
        expect(thread.subscribers).to include(user)
        GroupMembership.observers.enable :group_membership_observer do
          group_membership.destroy
        end
        thread.reload
        expect(thread.subscribers).not_to include(user)
      end
    end

    context "public threads" do
      let(:thread) { create(:group_message_thread) }
      it "should leave you subscribed to group public threads" do
        thread.add_subscriber(user)
        expect(thread.subscribers).to include(user)
        GroupMembership.observers.enable :group_membership_observer do
          group_membership.destroy
        end
        thread.reload
        expect(thread.subscribers).to include(user)
      end
    end
  end
end
