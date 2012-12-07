require "spec_helper"

describe NewThreadNotifier do
  subject { NewThreadNotifier }

  # Queueing interface
  it { subject.queue.should == :outbound_mail }
  it { should respond_to(:perform) }

  describe ".notify_new_thread" do
    it "should queue queue_new_thread with the thread id" do
      thread = mock("thread", id: 99)
      Resque.should_receive(:enqueue).with(NewThreadNotifier, :queue_new_thread, 99)
      subject.notify_new_thread(thread)
    end
  end

  describe ".queue_new_thread" do
    it "should queue notify_new_group_thread if thread belongs to a group"
  end

  describe ".notify_new_group_thread" do
    it "should queue send_new_group_thread_notification for each user"
  end

  describe ".send_new_group_thread_notification" do
    it "should send an email to the user given about the new thread"
  end
end
