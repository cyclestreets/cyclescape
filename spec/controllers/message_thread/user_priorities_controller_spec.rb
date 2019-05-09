# frozen_string_literal: true

require "spec_helper"

describe MessageThread::UserPrioritiesController, type: :controller do
  let(:thread)   { create :message_thread }
  let(:user)     { create :user }
  let(:priority) { 6 }
  before do
    warden.set_user user
  end

  describe "PUT update.json" do
    subject { put :update, params: { thread_id: thread.id, user_thread_priority: { priority: priority }, format: :js } }

    it "should respond" do
      expect(subject.body).to include("Priority updated")
    end

    it "should create a thread priority" do
      subject
      expect(thread.reload.priority_for(user).priority).to eq(6)
    end

    context "with an existing priority" do
      before do
        thread.user_priorities.create user: user, priority: 1
      end

      it "should update the thread priority" do
        subject
        expect(thread.reload.priority_for(user).priority).to eq(6)
      end

      context "it can be unset" do
        let(:priority) { nil }

        it "should update the thread priority" do
          subject
          expect(thread.reload.priority_for(user).priority).to eq(nil)
        end
      end
    end
  end
end
