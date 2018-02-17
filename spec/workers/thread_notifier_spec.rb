require 'spec_helper'

describe ThreadNotifier do
  subject { ThreadNotifier }

  # Queuing interface
  it { expect(subject.queue).to eq(:mailers) }
  it { expect(subject).to respond_to(:perform) }

  describe '.perform' do
    it 'should call the given method with the arguments' do
      expect(subject).to receive('test_method').with(1, :two, ['three'])
      subject.perform('test_method', 1, :two, ['three'])
    end
  end

  describe '.notify_subscribers' do
    it 'should create a job to process the subscribers list' do
      user_one = double('User', id: 101)
      user_two = double('User', id: 102)
      subscribers = [user_one, user_two]
      thread = double('MessageThread', id: 31, email_subscribers: subscribers)
      message = double('Message', id: 32)

      mail = double('mail')

      expect(ThreadMailer).to receive(:common).with(message, user_one).and_return(mail)
      expect(ThreadMailer).to receive(:common).with(message, user_two).and_return(mail)
      expect(mail).to receive(:deliver_later).twice

      subject.notify_subscribers(thread, message)
    end
  end
end
