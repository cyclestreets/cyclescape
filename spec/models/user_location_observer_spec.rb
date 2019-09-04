# frozen_string_literal: true

require "spec_helper"

describe UserLocationObserver do
  subject { UserLocationObserver.instance }

  context "basic checks" do
    let(:ul) { build(:user_location) }

    it "should notice when UserLocations are saved" do
      expect(subject).to receive(:after_save)

      UserLocation.observers.enable :user_location_observer do
        ul.save
      end
    end
  end

  context "adding a location" do
    let(:issue) { create(:issue) }
    let!(:thread) { create(:issue_message_thread, issue: issue) }
    let(:user_location) { build(:user_location, location: issue.location, user: user) }
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    context "with pref" do
      before do
        user.prefs.update_column(:involve_my_locations, "subscribe")
      end

      it "should subscribe users to existing threads" do
        expect(thread.subscribers).not_to include(user)
        UserLocation.observers.enable :user_location_observer do
          user_location.save
        end
        thread.reload
        expect(thread.subscribers).to include(user)
      end

      it "should not subscribe users to private threads" do
        expect(group.members).not_to include(user)
        thread.group = group
        thread.privacy = "group"
        thread.save
        UserLocation.observers.enable :user_location_observer do
          user_location.save
        end
        thread.reload
        expect(thread.subscribers).not_to include(user)
      end
    end

    context "without pref" do
      before do
        user.prefs.update_column(:involve_my_locations, "notify")
      end

      it "should not subscribe users to existing threads" do
        expect(thread.subscribers).not_to include(user)
        UserLocation.observers.enable :user_location_observer do
          user_location.save
        end
        thread.reload
        expect(thread.subscribers).not_to include(user)
      end
    end
  end

  context "destroying a location" do
    let(:issue) { create(:issue) }
    let!(:thread) { create(:issue_message_thread, issue: issue) }
    let(:user_location) { create(:user_location, location: issue.location) }
    let(:user) { user_location.user }

    before do
      user.prefs.update_column(:involve_my_locations, "subscribe")
      thread.add_subscriber(user)
    end

    it "should remove subscription" do
      expect(thread.subscribers).to include(user)
      UserLocation.observers.enable :user_location_observer do
        user_location.destroy
      end
      thread.reload
      expect(thread.subscribers).not_to include(user)
    end

    context "with a group thread and involve_my_groups set to subscribe" do
      let!(:group_membership) { create(:group_membership, user: user) }

      before do
        thread.group = group_membership.group
        thread.save
        user.prefs.update_column(:involve_my_groups, "subscribe")
      end

      it "should not remove subscription" do
        expect(thread.subscribers).to include(user)
        UserLocation.observers.enable :user_location_observer do
          user_location.destroy
        end
        thread.reload
        expect(thread.subscribers).to include(user)
      end
    end
  end
end
