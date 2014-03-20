require 'spec_helper'

describe UserPrefObserver do
  subject { UserPrefObserver.instance }

  context 'basic checks' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should notice when UserPrefs are saved' do
      user # triggers initial creation events which we want to ignore

      subject.should_receive(:after_save)
      UserPref.observers.enable :user_pref_observer do
        user.prefs.save
      end
    end
  end

  context 'administrative discussions' do
    let(:group_membership) { FactoryGirl.create(:group_membership) }
    let(:group_thread) { FactoryGirl.create(:message_thread, group: group_membership.group) }
    let(:group_issue_thread) { FactoryGirl.create(:issue_message_thread, group: group_membership.group) }
    let(:group_private_thread) { FactoryGirl.create(:message_thread, group: group_membership.group, privacy: 'committee') }
    let(:user) { group_membership.user }

    context 'when enabling pref' do
      before do
        user.prefs.update_column(:involve_my_groups_admin, false)
      end

      it 'should subscribe to group administrative threads' do
        group_thread.subscribers.should_not include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = true
          user.prefs.save
        end
        group_thread.reload
        group_thread.subscribers.should include(user)
      end

      it 'should not subscribe to group issue threads' do
        group_issue_thread.subscribers.should_not include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = true
          user.prefs.save
        end
        group_issue_thread.reload
        group_issue_thread.subscribers.should_not include(user)
      end

      it 'should not subscribe to committee admin threads if user not on committee' do
        group_private_thread.subscribers.should_not include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = true
          user.prefs.save
        end
        group_private_thread.reload
        group_private_thread.subscribers.should_not include(user)
      end

      it 'should not subscribe to threads that have been previously unsubscribed' do
        group_thread.add_subscriber(user)
        user.thread_subscriptions.to(group_thread).destroy
        group_thread.subscribers.should_not include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = true
          user.prefs.save
        end
        group_thread.reload
        group_thread.subscribers.should_not include(user)
      end
    end

    context 'when disabling pref' do
      before do
        user.prefs.update_column(:involve_my_groups_admin, true)
      end

      it 'should unsubscribe you from administrative threads' do
        group_thread.add_subscriber(user)
        group_thread.subscribers.should include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = false
          user.prefs.save
        end
        group_thread.reload
        group_thread.subscribers.should_not include(user)
      end

      it 'should not unsubcribe you from issue threads' do
        group_issue_thread.add_subscriber(user)
        group_issue_thread.subscribers.should include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups_admin = false
          user.prefs.save
        end
        group_issue_thread.reload
        group_issue_thread.subscribers.should include(user)
      end
    end
  end

  context 'involve my group issue discussions' do
    let(:group_membership) { FactoryGirl.create(:group_membership) }
    let(:group_thread) { FactoryGirl.create(:message_thread, group: group_membership.group) }
    let(:group_issue_thread) { FactoryGirl.create(:issue_message_thread, group: group_membership.group) }
    let(:group_private_thread) { FactoryGirl.create(:issue_message_thread, group: group_membership.group, privacy: 'committee') }
    let(:user) { group_membership.user }

    context 'when preference becomes subscribe' do
      before do
        user.prefs.update_column(:involve_my_groups, 'none') # could be 'notify' too
      end

      it 'should not subscribe to group administrative threads' do
        group_thread.subscribers.should_not include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'subscribe'
          user.prefs.save
        end
        group_thread.reload
        group_thread.subscribers.should_not include(user)
      end

      it 'should subscribe to issue threads' do
        group_issue_thread.subscribers.should_not include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'subscribe'
          user.prefs.save
        end
        group_issue_thread.reload
        group_issue_thread.subscribers.should include(user)
      end

      it 'should not subscribe to issue threads if user has no permissions' do
        group_private_thread.subscribers.should_not include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'subscribe'
          user.prefs.save
        end
        group_private_thread.reload
        group_private_thread.subscribers.should_not include(user)
      end

      it 'should not subscribe to threads that have been previously unsubscribed' do
        group_issue_thread.add_subscriber(user)
        user.thread_subscriptions.to(group_issue_thread).destroy
        group_issue_thread.subscribers.should_not include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'subscribe'
          user.prefs.save
        end
        group_issue_thread.reload
        group_issue_thread.subscribers.should_not include(user)
      end
    end

    context 'when preference is no longer subscribe' do
      before do
        user.prefs.update_column(:involve_my_groups, 'subscribe')
      end

      it 'should unsubscribe from issue threads' do
        group_issue_thread.add_subscriber(user)
        group_issue_thread.subscribers.should include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'none'
          user.prefs.save
        end
        group_issue_thread.reload
        group_issue_thread.subscribers.should_not include(user)
      end

      it 'should not unsubcribe from administrative threads' do
        group_thread.add_subscriber(user)
        group_thread.subscribers.should include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_groups = 'none'
          user.prefs.save
        end
        group_thread.reload
        group_thread.subscribers.should include(user)
      end

      context 'when involve my locations is subscribe' do
        let!(:user_location) { FactoryGirl.create(:user_location, user: user, location: group_issue_thread.issue.location) }

        before do
          user.prefs.update_column(:involve_my_locations, 'subscribe')
        end

        it 'should not unsubscribe from issue in user locations' do
          group_issue_thread.add_subscriber(user)
          group_issue_thread.subscribers.should include(user)
          UserPref.observers.enable :user_pref_observer do
            user.prefs.involve_my_groups = 'none'
            user.prefs.save
          end
          group_issue_thread.reload
          group_issue_thread.subscribers.should include(user)
        end
      end
    end
  end

  context 'involve my locations discussions' do
    let(:issue_thread) { FactoryGirl.create(:issue_message_thread) }
    let(:user_location) { FactoryGirl.create(:user_location, location: issue_thread.issue.location) }
    let(:user) { user_location.user }

    context 'when pref becomes subscribe' do
      before do
        user.prefs.update_column(:involve_my_locations, 'none') # could be 'notify' too
      end

      it 'should subscribe you to overlapping threads' do
        issue_thread.subscribers.should_not include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_locations = 'subscribe'
          user.prefs.save
        end
        issue_thread.reload
        issue_thread.subscribers.should include(user)
      end

      it 'should not subscribe you to private threads' do
        issue_thread.update_column(:privacy, 'private')
        issue_thread.subscribers.should_not include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_locations = 'subscribe'
          user.prefs.save
        end
        issue_thread.reload
        issue_thread.subscribers.should_not include(user)
      end
    end

    context 'when pref is no longer subscribe' do
      before do
        user.prefs.update_column(:involve_my_locations, 'subscribe')
      end

      it 'should unsubscribe from threads' do
        issue_thread.add_subscriber(user)
        issue_thread.subscribers.should include(user)
        UserPref.observers.enable :user_pref_observer do
          user.prefs.involve_my_locations = 'none'
          user.prefs.save
        end
        issue_thread.reload
        issue_thread.subscribers.should_not include(user)
      end

      context 'when involve by groups is subscribe' do
        let(:group_membership) { FactoryGirl.create(:group_membership, user: user) }

        before do
          user.prefs.update_column(:involve_my_groups, 'subscribe')
          issue_thread.group = group_membership.group
          issue_thread.save
        end

        it 'should not unsubscribe from group threads' do
          issue_thread.add_subscriber(user)
          user.groups.should include(issue_thread.group)
          issue_thread.subscribers.should include(user)
          UserPref.observers.enable :user_pref_observer do
            user.prefs.involve_my_locations = 'none'
            user.prefs.save
          end
          issue_thread.reload
          issue_thread.subscribers.should include(user)
        end
      end
    end
  end
end
