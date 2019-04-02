require 'spec_helper'

describe MessageThreadsController do
  let(:thread) { create(:message_thread) }

  describe 'thread views' do
    let!(:message_a) { create(:message, thread: thread, created_at: Time.now - 4.days) }
    let!(:message_b) { create(:message, thread: thread, created_at: Time.now - 3.days) }
    let!(:message_c) { create(:message, thread: thread, created_at: Time.now - 2.days) }

    context 'as a guest' do
      it 'should not assign a message to view from' do
        get :show, params: { id: thread.id }
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
          get :show, params: { id: thread.id }
          expect(assigns(:view_from)).to be_nil
        end
      end

      context 'who viewed the thread and no messages have been posted since' do
        it 'should assign the final message' do
          create(:thread_view, thread: thread, user: user, viewed_at: Time.now - 1.day)
          thread.reload
          get :show, params: { id: thread.id }
          expect(assigns(:view_from)).to eql(thread.messages.last)
        end
      end

      context 'who viewed the thread and two messages have been posted since' do
        it 'should assign the first of the new messages' do
          create(:thread_view, thread: thread, user: user, viewed_at: Time.now - 3.5.days)
          get :show, params: { id: thread.id }
          expect(assigns(:view_from)).to eql(message_b)
        end
      end
    end
  end

  describe 'closing / opening' do
    before do
      warden.set_user user_type
    end

    let(:subscription)   { create :thread_subscription, thread: thread }
    let(:subscriber)     { subscription.user }
    let(:non_subscriber) { create :user }

    describe 'closing' do
      subject { put :close, params: { id: thread.id } }

      context 'as a subscriber' do
        let(:user_type) { subscriber }

        it "can close the thread" do
          expect(subject.status).to eq 302
          expect(subject).to redirect_to "/threads/#{thread.id}"
        end
      end

      context 'as a non subscriber' do
        let(:user_type) { non_subscriber }

        it { expect(subject.status).to eq 401 }
      end
    end

    describe 'opening' do
      before { thread.update_column(:closed, true) }

      subject { put :open, params: { id: thread.id } }

      context 'as a subscriber' do
        let(:user_type) { subscriber }

        it "can open the thread" do
          expect(subject.status).to eq 302
          expect(subject).to redirect_to "/threads/#{thread.id}"
        end
      end

      context 'as a non subscriber' do
        let(:user_type) { non_subscriber }

        it { expect(subject.status).to eq 401 }
      end
    end
  end
end
