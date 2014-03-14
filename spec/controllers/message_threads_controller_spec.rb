require 'spec_helper'

describe MessageThreadsController do
  context 'thread views' do
    let(:thread) { FactoryGirl.create(:message_thread) }
    let!(:message_a) { FactoryGirl.create(:message, thread: thread, created_at: Time.now - 4.days) }
    let!(:message_b) { FactoryGirl.create(:message, thread: thread, created_at: Time.now - 3.days) }
    let!(:message_c) { FactoryGirl.create(:message, thread: thread, created_at: Time.now - 2.days) }

    context 'as a guest' do
      it 'should not assign a message to view from' do
        get :show, id: thread.id
        assigns(:view_from).should be_nil
      end
    end

    context 'as a site user' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        sign_in user
      end

      context "who hasn't viewed the thread before" do
        it 'should not assign a message to view from' do
          get :show, id: thread
          assigns(:view_from).should be_nil
        end
      end

      context 'who viewed the thread and no messages have been posted since' do
        it 'should assign the final message' do
          tv = FactoryGirl.create(:thread_view, thread: thread, user: user, viewed_at: Time.now - 1.day)
          get :show, id: thread
          assigns(:view_from).should eql(thread.messages.last)
        end
      end

      context 'who viewed the thread and two messages have been posted since' do
        it 'should assign the first of the new messages' do
          tv = FactoryGirl.create(:thread_view, thread: thread, user: user, viewed_at: Time.now - 3.5.days)
          get :show, id: thread
          assigns(:view_from).should eql(message_b)
        end
      end
    end
  end
end
