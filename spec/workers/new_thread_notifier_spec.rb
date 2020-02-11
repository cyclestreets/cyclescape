# frozen_string_literal: true

require "spec_helper"

describe NewThreadNotifier do
  subject { NewThreadNotifier }

  # Queueing interface
  it { expect(subject.queue).to eq(:mailers) }
  it { is_expected.to respond_to(:perform) }

  describe ".notify_new_thread" do
    it "should queue queue_new_thread with the thread id" do
      thread = double("thread", id: 99)
      expect(Resque).to receive(:enqueue).with(NewThreadNotifier, :queue_new_thread, 99)
      subject.notify_new_thread(thread)
    end
  end

  describe ".queue_new_thread" do
    it "should queue notify_new_group_thread if thread belongs to a group"
  end

  describe ".notify_new_group_thread" do
    let(:group) { thread.group }
    let(:issue) { create :issue }
    let(:thread) { create :message_thread, :belongs_to_group, issue: issue }

    before do
      user.prefs.update_columns(involve_my_groups: "notify", email_status_id: 1)
    end

    context "when the user did not create the issue" do
      let(:user) { create(:group_membership, group: group).user }

      it "should queue send_new_group_thread_notification for each user" do
        opts = { "member_id" => user.id, "thread_id" => thread.id }
        expect(Resque).to receive(:enqueue).with(NewThreadNotifier, :send_new_group_thread_notification, opts)

        described_class.queue_new_thread(thread.id)
      end
    end

    context "when the user created the thread" do
      let(:user) { thread.created_by }

      it "should not notify the thread creator" do
        expect(group.members).to include(user) # Due to the factories

        expect(Resque).not_to receive(:enqueue)

        described_class.queue_new_thread(thread.id)
      end
    end
  end

  describe ".send_new_group_thread_notification" do
    it "should send an email to the user given about the new thread"
  end
end
