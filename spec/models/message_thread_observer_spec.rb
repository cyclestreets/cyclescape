require 'spec_helper'

describe MessageThreadObserver do
  subject { MessageThreadObserver.instance }

  context 'basic checks' do
    let(:thread) { FactoryGirl.build(:message_thread) }

    it 'should notice when MessageThreads are saved' do
      expect(subject).to receive(:after_save)

      MessageThread.observers.enable :message_thread_observer do
        thread.save
      end
    end
  end

  context 'privacy' do
    let(:user) { FactoryGirl.create(:user) }
    let(:membership) { FactoryGirl.create(:group_membership, group: thread.group) }
    let(:member) { membership.user }
    let(:committee_membership) { FactoryGirl.create(:group_membership, group: thread.group, role: 'committee') }
    let(:committee_member) { committee_membership.user }

    context 'from public' do
      let(:thread) { FactoryGirl.create(:message_thread, :belongs_to_group) }

      context 'to group' do
        it 'should unsubscribe non-group members' do
          thread.add_subscriber(user)
          expect(thread.subscribers).to include(user)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = 'group'
            thread.save
          end
          thread.reload
          expect(thread.subscribers).not_to include(user)
        end

        it 'should leave group members subscribed' do
          thread.add_subscriber(member)
          expect(thread.subscribers).to include(member)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = 'group'
            thread.save
          end
          thread.reload
          expect(thread.subscribers).to include(member)
        end
      end

      context 'to committee' do
        it 'should unsubscribe group members' do
          thread.add_subscriber(member)
          expect(thread.subscribers).to include(member)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = 'committee'
            thread.save
          end
          thread.reload
          expect(thread.subscribers).not_to include(member)
        end

        it 'should leave committee members subscribed' do
          thread.add_subscriber(committee_member)
          expect(thread.subscribers).to include(committee_member)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = 'committee'
            thread.save
          end
          thread.reload
          expect(thread.subscribers).to include(committee_member)
        end
      end
    end

    context 'from group private' do
      let(:thread) { FactoryGirl.create(:message_thread, :belongs_to_group, :private) }

      context 'to public' do
        it 'should try subscribe people who might have access' do
          expect(ThreadSubscriber).to receive(:subscribe_users).with(thread)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = 'public'
            thread.save
          end
        end
      end

      context 'to committee' do
        it 'should unsubscribe group members' do
          thread.add_subscriber(member)
          expect(thread.subscribers).to include(member)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = 'committee'
            thread.save
          end
          thread.reload
          expect(thread.subscribers).not_to include(member)
        end

        it 'should leave committee members subscribed' do
          thread.add_subscriber(committee_member)
          expect(thread.subscribers).to include(committee_member)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = 'committee'
            thread.save
          end
          thread.reload
          expect(thread.subscribers).to include(committee_member)
        end
      end
    end

    context 'from committee' do
      let(:thread) { FactoryGirl.create(:message_thread, :belongs_to_group, :committee) }

      context 'to group' do
        it 'should attempt to subscribe group members' do
          expect(ThreadSubscriber).to receive(:subscribe_users).with(thread)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = 'group'
            thread.save
          end
        end
      end

      context 'to public' do
        it 'should subscribe people with overlapping locations' do
          expect(ThreadSubscriber).to receive(:subscribe_users).with(thread)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = 'public'
            thread.save
          end
        end
      end
    end
  end

  context 'issue' do
    context 'added' do
      let(:thread) { FactoryGirl.create(:message_thread, :belongs_to_group) }
      let(:private_thread) { FactoryGirl.create(:message_thread, :belongs_to_group, :private) }
      let(:user_location) { FactoryGirl.create(:user_location) }
      let(:issue) { FactoryGirl.create(:issue, location: user_location.location) }

      it 'should subscribe people with overlapping locations' do
        MessageThread.observers.enable :message_thread_observer do
          thread.issue = issue
          thread.save
        end
        thread.reload
        expect(thread.subscribers).to include(user_location.user)
      end

      it "should not subscribe people who can't view it" do
        MessageThread.observers.enable :message_thread_observer do
          private_thread.issue = issue
          private_thread.save
        end
        thread.reload
        expect(thread.subscribers).not_to include(user_location.user)
      end
    end

    context 'removed' do
      let(:user) { FactoryGirl.create(:user) }
      let(:thread) { FactoryGirl.create(:issue_message_thread) }
      let!(:subscription) { FactoryGirl.create(:thread_subscription, thread: thread, user: user) }

      it 'should remove people' do
        expect(thread.subscribers).to include(user)
        MessageThread.observers.enable :message_thread_observer do
          thread.issue = nil
          thread.save
        end
        thread.reload
        expect(thread.subscribers).not_to include(user)
      end

      it 'should leave people subscribed if they have participated' do
        FactoryGirl.create(:message, thread: thread, created_by: user)
        expect(thread.subscribers).to include(user)
        expect(thread.participants).to include(user)
        MessageThread.observers.enable :message_thread_observer do
          thread.issue = nil
          thread.save
        end
        thread.reload
        expect(thread.subscribers).to include(user)
      end

      context 'becomes group administrative thread' do
        let(:thread) { FactoryGirl.create(:group_message_thread) }
        let(:group_membership) { FactoryGirl.create(:group_membership, group: thread.group) }
        let(:member) { group_membership.user }
        let!(:subscription) { FactoryGirl.create(:thread_subscription, thread: thread, user: member) }

        before do
          member.prefs.involve_my_groups_admin = true
          member.save
        end

        it 'should leave people subscribed if they have their administrative pref set' do
          MessageThread.observers.enable :message_thread_observer do
            thread.issue = nil
            thread.save
          end
          thread.reload
          expect(thread.subscribers).to include(member)
        end
      end
    end

    context 'changed' do
      it 'should not remove and then add the same person again'
    end
  end

  context 'group' do
    context 'added' do
      it 'should subscribe people with group preference set'
    end

    context 'removed' do
      it 'should leave people subscribed if they have participated'
      it 'should remove people'
    end
  end
end
