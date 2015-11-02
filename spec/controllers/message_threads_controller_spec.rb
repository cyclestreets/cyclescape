require 'spec_helper'

describe MessageThreadsController do
  context 'thread views' do
    let(:thread) { create(:message_thread) }
    let!(:message_a) { create(:message, thread: thread, created_at: Time.now - 4.days) }
    let!(:message_b) { create(:message, thread: thread, created_at: Time.now - 3.days) }
    let!(:message_c) { create(:message, thread: thread, created_at: Time.now - 2.days) }

    context 'as a guest' do
      it 'should not assign a message to view from' do
        get :show, id: thread.id
        expect(assigns(:view_from)).to be_nil
      end
    end

    context 'as a site user' do
      let(:user) { create(:user) }

      before do
        warden.set_user user
      end

      context "who hasn't viewed the thread before" do
        it 'should not assign a message to view from' do
          get :show, id: thread
          expect(assigns(:view_from)).to be_nil
        end
      end

      context 'who viewed the thread and no messages have been posted since' do
        it 'should assign the final message' do
          create(:thread_view, thread: thread, user: user, viewed_at: Time.now - 1.day)
          thread.reload
          get :show, id: thread
          expect(assigns(:view_from)).to eql(thread.messages.last)
        end
      end

      context 'who viewed the thread and two messages have been posted since' do
        it 'should assign the first of the new messages' do
          create(:thread_view, thread: thread, user: user, viewed_at: Time.now - 3.5.days)
          get :show, id: thread
          expect(assigns(:view_from)).to eql(message_b)
        end
      end
    end
  end

  describe 'approve' do
    let(:message_thread)   { create(:message_thread, :belongs_to_group, :with_messages, status: 'mod_queued') }
    let(:group)            { message_thread.group }
    let(:committee_member) { create(:user).tap{ |usr| create(:group_membership, :committee, user: usr, group: group) } }
    let(:other_user)       { create(:group_membership, :committee).user }

    before do
      warden.set_user user_type
    end

    subject { put :approve, id: message_thread.id, format: :js }

    context 'for a committee member' do
      let!(:req)      { stub_request(:post, /rest\.akismet\.com\/1\.1\/submit-ham/).to_return(status: 200) }
      let(:user_type) { committee_member }

      it { expect(subject.status).to eq(200) }
      it { subject; expect(req).to have_been_made }
    end

    context 'for a non committee member' do
      let(:user_type) { other_user }
      it { expect(subject.status).to eq(401) }
    end
  end
end
