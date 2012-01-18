require "spec_helper"

describe ThreadNotifier do
  subject { ThreadNotifier }

  # Queuing interface
  it { subject.queue.should == :outbound_mail }
  it { subject.should respond_to(:perform) }

  describe ".perform" do
    it "should call the given method with the arguments" do
      subject.should_receive("test_method").with(1, :two, ["three"])
      subject.perform("test_method", 1, :two, ["three"])
    end
  end

  describe ".notify_subscribers" do
    it "should create a job to process the subscribers list" do
      thread = double(id: 31)
      message = double(id: 32)
      Resque.should_receive(:enqueue).with(ThreadNotifier, :queue_messages_for_subscribers, thread.id, "new_message", message.id)
      subject.notify_subscribers(thread, "new_message", message)
    end
  end

  describe ".queue_messages_for_subscribers" do
    it "should create a job for each subscriber to a thread" do
      subscribers = [double(id: 101), double(id: 102)]
      thread = double("thread", id: 31, email_subscribers: subscribers)
      MessageThread.should_receive(:find).with(thread.id).and_return(thread)
      Resque.should_receive(:enqueue).with(ThreadNotifier, :send_notification, "new_message", 32, 101)
      Resque.should_receive(:enqueue).with(ThreadNotifier, :send_notification, "new_message", 32, 102)
      subject.queue_messages_for_subscribers(thread.id, "new_message", 32)
    end
  end

  describe ".send_notification" do
    it "should send an email notification" do
      thread = double("thread")
      subscriber = double("subscriber", id: 201)
      subscribers = double("subscribers")
      thread.stub!(:subscribers).and_return(subscribers)
      message = double("message", id: 32, thread: thread)
      mail = double("mail")

      Message.should_receive(:find).with(message.id).and_return(message)
      subscribers.should_receive(:find).with(subscriber.id).and_return(subscriber)
      ThreadMailer.should_receive(:new_message).with(message, subscriber).and_return(mail)
      mail.should_receive(:deliver)

      subject.send_notification("new_message", message.id, subscriber.id)
    end
  end
end
