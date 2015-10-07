require 'spec_helper'

describe ThreadNotifier do
  subject { ThreadNotifier }

  # Queuing interface
  it { expect(subject.queue).to eq(:outbound_mail) }
  it { expect(subject).to respond_to(:perform) }

  describe '.perform' do
    it 'should call the given method with the arguments' do
      expect(subject).to receive('test_method').with(1, :two, ['three'])
      subject.perform('test_method', 1, :two, ['three'])
    end
  end

  describe '.notify_subscribers' do
    it 'should create a job to process the subscribers list' do
      thread = double(id: 31)
      message = double(id: 32)
      expect(Resque).to receive(:enqueue).with(ThreadNotifier, :queue_messages_for_subscribers, thread.id, 'new_message', message.id)
      subject.notify_subscribers(thread, 'new_message', message)
    end
  end

  describe '.queue_messages_for_subscribers' do
    it 'should create a job for each subscriber to a thread' do
      subscribers = [double(id: 101), double(id: 102)]
      thread = double('thread', id: 31, email_subscribers: subscribers)
      expect(MessageThread).to receive(:find).with(thread.id).and_return(thread)
      expect(Resque).to receive(:enqueue).with(ThreadNotifier, :send_notification, 'new_message', 32, 101)
      expect(Resque).to receive(:enqueue).with(ThreadNotifier, :send_notification, 'new_message', 32, 102)
      subject.queue_messages_for_subscribers(thread.id, 'new_message', 32)
    end
  end

  describe '.send_notification' do
    it 'should send an email notification' do
      thread = double('thread')
      subscriber = double('subscriber', id: 201)
      subscribers = double('subscribers')
      allow(thread).to receive(:subscribers).and_return(subscribers)
      message = double('message', id: 32, thread: thread)
      mail = double('mail')

      expect(Message).to receive(:find).with(message.id).and_return(message)
      expect(subscribers).to receive(:find).with(subscriber.id).and_return(subscriber)
      expect(ThreadMailer).to receive(:new_message).with(message, subscriber).and_return(mail)
      expect(mail).to receive(:deliver_now)

      subject.send_notification('new_message', message.id, subscriber.id)
    end
  end
end
