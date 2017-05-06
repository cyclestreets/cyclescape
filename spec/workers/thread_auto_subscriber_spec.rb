require 'spec_helper'

describe ThreadAutoSubscriber, after_commit: true  do
  context 'privacy' do
    let(:user) { create(:user) }
    let(:membership) { create(:group_membership, group: thread.group) }
    let(:member) { membership.user }
    let(:committee_membership) { create(:group_membership, group: thread.group, role: 'committee') }
    let(:committee_member) { committee_membership.user }

    context "being deleted" do
      subject! { create(:message_thread) }
      it "should do nothing" do
        expect{ subject.destroy }.to_not raise_error
      end
    end

    context 'from public' do
      let!(:thread) { create(:message_thread, :belongs_to_group) }

      context 'to group' do
        it 'should unsubscribe non-group and leave members' do
          thread.add_subscriber(user)
          expect(thread.subscribers).to include(user)

          thread.add_subscriber(member)
          expect(thread.subscribers).to include(member)

          thread.update!(privacy: 'group')

          expect(thread.subscribers.reload).not_to include(user)
          expect(thread.subscribers).to include(member)
        end
      end

      context 'to committee' do
        it 'should unsubscribe group members' do
          thread.add_subscriber(member)
          expect(thread.subscribers).to include(member)

          thread.add_subscriber(committee_member)
          expect(thread.subscribers).to include(committee_member)

          thread.update(privacy: 'committee')

          thread.reload
          expect(thread.subscribers).not_to include(member)
          expect(thread.subscribers).to include(committee_member)
        end
      end
    end

    context 'from group private' do
      let(:thread) { create(:message_thread, :belongs_to_group, :private) }

      context 'to committee' do
        it 'should unsubscribe group members' do
          thread.add_subscriber(member)
          expect(thread.subscribers).to include(member)

          thread.add_subscriber(committee_member)
          expect(thread.subscribers).to include(committee_member)

          thread.update(privacy: 'committee')

          thread.reload

          expect(thread.subscribers).not_to include(member)
          expect(thread.subscribers).to include(committee_member)
        end
      end
    end
  end

  context 'issue' do
    context 'added' do
      let(:thread) { create(:message_thread, :belongs_to_group) }
      let(:private_thread) { create(:message_thread, :belongs_to_group, :private) }
      let(:user_location) { create(:user_location) }
      let(:issue) { create(:issue, location: user_location.location) }

      it 'should subscribe people with overlapping locations' do
        thread.update(issue: issue)
        thread.reload
        expect(thread.subscribers).to include(user_location.user)
      end

      it "should not subscribe people who can't view it" do
        private_thread.update(issue: issue)
        thread.reload
        expect(thread.subscribers).not_to include(user_location.user)
      end
    end

    context 'removed' do
      let(:user) { create(:user) }
      let(:thread) { create(:issue_message_thread) }
      let!(:subscription) { create(:thread_subscription, thread: thread, user: user) }

      it 'should remove people' do
        expect(thread.subscribers).to include(user)
        thread.update(issue: nil)

        thread.reload
        expect(thread.subscribers).not_to include(user)
      end

      it 'should leave people subscribed if they have participated' do
        create(:message, thread: thread, created_by: user)
        expect(thread.subscribers).to include(user)
        expect(thread.participants).to include(user)

        thread.update(issue: nil)
        expect(thread.subscribers).to include(user)
      end

      context 'becomes group administrative thread' do
        let(:thread) { create(:group_message_thread) }
        let(:group_membership) { create(:group_membership, group: thread.group) }
        let(:member) { group_membership.user }
        let!(:subscription) { create(:thread_subscription, thread: thread, user: member) }

        before do
          member.prefs.update(involve_my_groups_admin: true)
        end

        it 'should leave people subscribed if they have their administrative pref set' do
          thread.update(issue: nil)
          thread.reload
          expect(thread.subscribers).to include(member)
        end
      end
    end

    context 'called thrice', db_truncate: true do
      it 'only runs once and queues up twice' do
        thread = create(:message_thread)
        allow(ThreadSubscriber).to receive(:subscribe_users).once { sleep 1 }
        expect(Resque).to receive(:enqueue).twice
        threads = []
        ActiveRecord::Base.connection.disconnect!
        3.times do |i|
          threads[i] = Thread.new do
            ActiveRecord::Base.establish_connection
            described_class.perform(thread.id, { "privacy" => "public" })
          end
        end
        threads.each(&:join)
        ActiveRecord::Base.establish_connection
      end
    end
  end
end
