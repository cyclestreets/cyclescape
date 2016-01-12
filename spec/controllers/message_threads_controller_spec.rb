require 'spec_helper'

describe MessageThreadsController do
  let(:thread) { create(:message_thread) }

  describe 'thread views' do
    let!(:message_a) { create(:message, thread: thread, created_at: Time.now - 4.days) }
    let!(:message_b) { create(:message, thread: thread, created_at: Time.now - 3.days) }
    let!(:message_c) { create(:message, thread: thread, created_at: Time.now - 2.days) }
    let!(:message_d) { create(:message, thread: thread, created_at: Time.now) }

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
          get :show, id: thread.id
          expect(assigns(:view_from)).to be_nil
        end
      end

      context 'who viewed the thread and no messages have been posted since' do
        it 'should assign the final message' do
          create(:thread_view, thread: thread, user: user, viewed_at: Time.now - 1.day)
          thread.reload
          get :show, id: thread.id
          expect(assigns(:view_from)).to eql(thread.messages.last)
        end
      end

      context 'who viewed the thread and two messages have been posted since' do
        it 'should assign the first of the new messages' do
          create(:thread_view, thread: thread, user: user, viewed_at: Time.now - 3.5.days)
          get :show, id: thread.id
          expect(assigns(:view_from)).to eql(message_b)
        end
      end

      # NOTE: This is probably where a spec should go for the thread linking.
      # Left out with this note per Martin.
      # context 'who viewed the thread' do
      #   it 'should contains a link to a threaded message' do
      #     create(:thread_view, thread: thread, user: user, viewed_at: Time.now)
      #     get :show, id: thread.id
      #     expect(assigns(:view_from)).to have_content('/threads/2')
      #   end
      # end
    end
  end

  describe 'closing / opening' do
    before do
      warden.set_user user_type
      create :message, thread: thread, updated_at: 49.hours.ago
    end

    let(:subscription)   { create :thread_subscription, thread: thread }
    let(:subscriber)     { subscription.user }
    let(:non_subscriber) { create :user }

    describe 'closing' do
      subject { put :close, id: thread.id }

      context 'as a subscriber' do
        let(:user_type) { subscriber }
        context 'more than 48 hours ago' do
          it { expect(subject.status).to eq 302 }
          it { expect(subject).to redirect_to "/threads/#{thread.id}" }
        end

        context 'less than 48 hours ago' do
          before { create :message, thread: thread, updated_at: 47.hours.ago }

          it { expect(subject.status).to eq 401 }
        end
      end

      context 'as a non subscriber' do
        let(:user_type) { non_subscriber }

        it { expect(subject.status).to eq 401 }
      end
    end

    describe 'opening' do
      before { thread.update_column(:closed, true) }

      subject { put :open, id: thread.id }

      context 'as a subscriber' do
        let(:user_type) { subscriber }

        it { expect(subject.status).to eq 302 }
        it { expect(subject).to redirect_to "/threads/#{thread.id}" }
      end

      context 'as a non subscriber' do
        let(:user_type) { non_subscriber }

        it { expect(subject.status).to eq 401 }
      end
    end
  end
end
