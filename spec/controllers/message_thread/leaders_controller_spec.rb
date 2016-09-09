require 'spec_helper'

describe MessageThread::LeadersController, type: :controller do
  let(:thread)      { create :message_thread, subscribers: subscribers }
  let(:user)        { create :user }
  let(:subscribers) { [] }

  before { warden.set_user user }

  describe 'POST create.html' do
    subject { post :create, thread_id: thread.id }

    context "when subscribed" do
      let(:subscribers) { [user] }
      it "sets flash, leader and emails" do
        expect(ThreadNotifier).to receive(:notify_subscribers_event).with(thread, :new_leader, user)
        subject
        expect(flash[:notice]).to be_present
        expect(thread.reload.leaders).to include(user)
        expect(response.status).to eq 302
      end
    end

    context "when not subscribed" do
      it "sets flash, leader and emails" do
        subject
        expect(response.status).to eq 401
      end
    end
  end
end
