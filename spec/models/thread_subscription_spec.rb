# frozen_string_literal: true

require "spec_helper"

describe ThreadSubscription do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:thread) }
  end

  context "when leading the thread" do
    let(:message_thread) { create :message_thread }
    let(:user) { create :user, leading_threads: [message_thread], subscribed_threads: [message_thread] }
    subject { user.thread_subscriptions.find_by(thread: message_thread) }

    it "stops leading when user stops subscribing" do
      expect { subject.destroy }.to change { user.reload.leading_threads.count }.from(1).to(0)
    end
  end
end
