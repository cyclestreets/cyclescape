require 'spec_helper'

describe ThreadRecorder do
  subject { ThreadRecorder }

  # Queuing interface
  it { expect(subject.queue).to eq(:thread_views) }
  it { expect(subject).to respond_to(:perform) }

  describe '.perform' do
    it 'should call the given method with the arguments' do
      expect(subject).to receive('test_method').with(1, :two, ['three'])
      subject.perform('test_method', 1, :two, ['three'])
    end
  end

  describe '.thread_viewed' do
    it 'should create a job to mark the thread as viewed' do
      thread = double(id: 31)
      user = double(id: 32)
      expect(Resque).to receive(:enqueue).with(ThreadRecorder, :record_thread_viewed, thread.id, user.id, kind_of(Time))
      subject.thread_viewed(thread, user)
    end
  end

  describe '.record_thread_viewed' do
    let(:user) { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }
    let(:time) { Time.now - 2.days }
    let(:time2) { Time.now - 1.day }

    it 'should record the time the thread was viewed at' do
      subject.record_thread_viewed(thread.id, user.id, time.to_s)
      expect(ThreadView.find_by_thread_id_and_user_id(thread.id, user.id).viewed_at.to_i).to eql(time.to_i)
    end

    it 'should update the ThreadView record, not add another one' do
      subject.record_thread_viewed(thread.id, user.id, time.to_s)
      subject.record_thread_viewed(thread.id, user.id, time2.to_s)
      expect(ThreadView.find_all_by_thread_id_and_user_id(thread.id, user.id).length).to eql(1)
      expect(ThreadView.find_by_thread_id_and_user_id(thread.id, user.id).viewed_at.to_i).to eql(time2.to_i)
    end
  end
end
