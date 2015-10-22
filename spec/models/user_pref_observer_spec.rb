require 'spec_helper'

describe UserPrefObserver do

  subject { UserPrefObserver.instance }

  context 'basic checks' do
    let(:user) { create(:user) }

    it 'should notice when UserPrefs are saved' do
      user # triggers initial creation events which we want to ignore

      expect(subject).to receive(:after_save)
      UserPref.observers.enable :user_pref_observer do
        user.prefs.save
      end
    end
  end

  context 'administrative discussions' do
    let(:group_membership) { create(:group_membership) }
    let(:group_thread) { create(:message_thread, group: group_membership.group) }
    let(:group_issue_thread) { create(:issue_message_thread, group: group_membership.group) }
    let(:group_private_thread) { create(:message_thread, group: group_membership.group, privacy: 'committee') }
    let(:user) { group_membership.user }

    context 'when enabling pref' do
      before do
        user.prefs.update_column(:involve_my_groups_admin, false)
      end

      it 'should subscribe to group administrative threads' do
        expect(group_thread.subscribers).not_to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = true
          user.prefs.save
        end
        group_thread.reload
        expect(group_thread.subscribers).to include(user)
      end

      it 'should not subscribe to group issue threads' do
        expect(group_issue_thread.subscribers).not_to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = true
          user.prefs.save
        end
        group_issue_thread.reload
        expect(group_issue_thread.subscribers).not_to include(user)
      end

      it 'should not subscribe to committee admin threads if user not on committee' do
        expect(group_private_thread.subscribers).not_to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = true
          user.prefs.save
        end
        group_private_thread.reload
        expect(group_private_thread.subscribers).not_to include(user)
      end

      it 'should not subscribe to threads that have been previously unsubscribed' do
        group_thread.add_subscriber(user)
        user.thread_subscriptions.to(group_thread).destroy
        expect(group_thread.subscribers).not_to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = true
          user.prefs.save
        end
        group_thread.reload
        expect(group_thread.subscribers).not_to include(user)
      end
    end

    context 'when disabling pref' do
      before do
        user.prefs.update_column(:involve_my_groups_admin, true)
      end

      it 'should unsubscribe you from administrative threads' do
        group_thread.add_subscriber(user)
        expect(group_thread.subscribers).to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = false
          user.prefs.save
        end
        group_thread.reload
        expect(group_thread.subscribers).not_to include(user)
      end

      it 'should not unsubcribe you from issue threads' do
        group_issue_thread.add_subscriber(user)
        expect(group_issue_thread.subscribers).to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = false
          user.prefs.save
        end
        group_issue_thread.reload
        expect(group_issue_thread.subscribers).to include(user)
      end
    end
  end

  context 'involve my group issue discussions' do
    let(:group_membership) { create(:group_membership) }
    let(:group_thread) { create(:message_thread, group: group_membership.group) }
    let(:group_issue_thread) { create(:issue_message_thread, group: group_membership.group) }
    let(:group_private_thread) { create(:issue_message_thread, group: group_membership.group, privacy: 'committee') }
    let(:user) { group_membership.user }

    context 'when preference becomes subscribe' do
      before do
        user.prefs.update_column(:involve_my_groups, 'none') # could be 'notify' too
      end

      it 'should not subscribe to group administrative threads' do
        expect(group_thread.subscribers).not_to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'subscribe'
          user.prefs.save
        end
        group_thread.reload
        expect(group_thread.subscribers).not_to include(user)
      end

      it 'should subscribe to issue threads' do
        expect(group_issue_thread.subscribers).not_to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'subscribe'
          user.prefs.save
        end
        group_issue_thread.reload
        expect(group_issue_thread.subscribers).to include(user)
      end

      it 'should not subscribe to issue threads if user has no permissions' do
        expect(group_private_thread.subscribers).not_to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'subscribe'
          user.prefs.save
        end
        group_private_thread.reload
        expect(group_private_thread.subscribers).not_to include(user)
      end

      it 'should not subscribe to threads that have been previously unsubscribed' do
        group_issue_thread.add_subscriber(user)
        user.thread_subscriptions.to(group_issue_thread).destroy
        expect(group_issue_thread.subscribers).not_to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'subscribe'
          user.prefs.save
        end
        group_issue_thread.reload
        expect(group_issue_thread.subscribers).not_to include(user)
      end
    end

    context 'when preference is no longer subscribe' do
      before do
        user.prefs.update_column(:involve_my_groups, 'subscribe')
      end

      it 'should unsubscribe from issue threads' do
        group_issue_thread.add_subscriber(user)
        expect(group_issue_thread.subscribers).to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'none'
          user.prefs.save
        end
        group_issue_thread.reload
        expect(group_issue_thread.subscribers).not_to include(user)
      end

      it 'should not unsubcribe from administrative threads' do
        group_thread.add_subscriber(user)
        expect(group_thread.subscribers).to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'none'
          user.prefs.save
        end
        group_thread.reload
        expect(group_thread.subscribers).to include(user)
      end

      context 'when involve my locations is subscribe' do
        let!(:user_location) { create(:user_location, user: user, location: group_issue_thread.issue.location) }

        before do
          user.prefs.update_column(:involve_my_locations, 'subscribe')
        end

        it 'should not unsubscribe from issue in user locations' do
          group_issue_thread.add_subscriber(user)
          expect(group_issue_thread.subscribers).to include(user)
          UserPref.observers.enable :user_pref_observer do
            user.prefs.involve_my_groups = 'none'
            user.prefs.save
          end
          group_issue_thread.reload
          expect(group_issue_thread.subscribers).to include(user)
        end
      end
    end
  end

  context 'involve my locations discussions' do
    let(:issue_thread) { create(:issue_message_thread) }
    let(:user_location) { create(:user_location, location: issue_thread.issue.location) }
    let(:user) { user_location.user }

    context 'when pref becomes subscribe' do
      before do
        user.prefs.update_column(:involve_my_locations, 'none') # could be 'notify' too
      end

      it 'should subscribe you to overlapping threads' do
        expect(issue_thread.subscribers).not_to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_locations = 'subscribe'
          user.prefs.save
        end
        issue_thread.reload
        expect(issue_thread.subscribers).to include(user)
      end

      it 'should not subscribe you to private threads' do
        issue_thread.update_column(:privacy, 'private')
        expect(issue_thread.subscribers).not_to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_locations = 'subscribe'
          user.prefs.save
        end
        issue_thread.reload
        expect(issue_thread.subscribers).not_to include(user)
      end
    end

    context 'when pref is no longer subscribe' do
      before do
        user.prefs.update_column(:involve_my_locations, 'subscribe')
        create(:issue_message_thread) # A thread the user is not subscribed to
      end

      let(:non_local_issue)  { create(:issue, location: 'POINT(-100 40)') }
      let(:non_local_thread) { create(:message_thread, issue: non_local_issue) }

      it 'should unsubscribe from threads' do
        issue_thread.add_subscriber(user)
        expect(issue_thread.subscribers).to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_locations = 'none'
          user.prefs.save
        end
        issue_thread.reload
        expect(issue_thread.subscribers).not_to include(user)
      end

      it 'should not unsubscribe from non local threads' do
        non_local_thread.add_subscriber(user)
        expect(non_local_thread.subscribers).to include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_locations = 'none'
          user.prefs.save
        end
        expect(non_local_thread.reload.subscribers).to include(user)
      end

      context 'when involve by groups is subscribe' do
        let(:group_membership) { create(:group_membership, user: user) }

        before do
          user.prefs.update_column(:involve_my_groups, 'subscribe')
          issue_thread.group = group_membership.group
          issue_thread.save
        end

        it 'should not unsubscribe from group threads' do
          issue_thread.add_subscriber(user)
          non_local_thread.add_subscriber(user)
          expect(user.groups).to include(issue_thread.group)
          expect(issue_thread.subscribers).to include(user)
          UserPref.observers.enable :user_pref_observer do
            user.prefs.involve_my_locations = 'none'
            user.prefs.save
          end
          issue_thread.reload
          expect(issue_thread.subscribers).to include(user)
        end
      end
    end
  end
end
