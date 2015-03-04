# == Schema Information
#
# Table name: message_threads
#
#  id            :integer          not null, primary key
#  issue_id      :integer
#  created_by_id :integer          not null
#  group_id      :integer
#  title         :string(255)      not null
#  privacy       :string(255)      not null
#  state         :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  public_token  :string(255)
#
# Indexes
#
#  index_message_threads_on_created_by_id  (created_by_id)
#  index_message_threads_on_group_id       (group_id)
#  index_message_threads_on_issue_id       (issue_id)
#  index_message_threads_on_public_token   (public_token) UNIQUE
#

require 'spec_helper'

describe MessageThread do
  it_should_behave_like 'a taggable model'

  describe 'associations' do
    it { is_expected.to belong_to(:created_by) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:issue) }
    it { is_expected.to have_many(:messages) }
    it { is_expected.to have_many(:subscriptions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:created_by_id) }
    it { is_expected.to allow_value('public').for(:privacy) }
    it { is_expected.to allow_value('group').for(:privacy) }
    it { is_expected.to allow_value('committee').for(:privacy) }
    it { is_expected.not_to allow_value('other').for(:privacy) }
  end

  describe 'privacy' do
    subject { MessageThread.new }

    it 'should become private to group' do
      expect(subject).not_to be_private_to_group
      subject.group = FactoryGirl.create(:group)
      subject.privacy = 'group'
      expect(subject).to be_private_to_group
      expect(subject).not_to be_private_to_committee
      expect(subject).not_to be_public
    end

    it 'should become private to committee' do
      expect(subject).not_to be_private_to_committee
      subject.group = FactoryGirl.create(:group)
      subject.privacy = 'committee'
      expect(subject).to be_private_to_committee
      expect(subject).not_to be_private_to_group
      expect(subject).not_to be_public
    end

    it 'should be public' do
      expect(subject).not_to be_public
      subject.privacy = 'public'
      expect(subject).to be_public
    end
  end

  describe 'participants' do
    it 'should have zero participants' do
      thread = FactoryGirl.create(:message_thread)
      expect(thread.participants.count).to eq(0)
    end

    it 'should have one participant' do
      thread = FactoryGirl.create(:message_thread_with_messages)
      expect(thread.participants.count).to eq(1)
    end
  end

  describe 'priorities' do
    let(:user) { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }
    let!(:priority) { FactoryGirl.create(:user_thread_priority, user: user, thread: thread) }

    it 'should confirm that user has prioritised' do
      expect(thread.priority_for(user)).to eq(priority)
    end
  end

  describe 'with messages from' do
    let(:user) { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }
    let(:message) { FactoryGirl.create(:message, thread: thread, created_by: user) }

    it 'should be empty' do
      expect(MessageThread.with_messages_from(user)).to be_empty
    end

    it 'should find one thread' do
      message
      expect(MessageThread.with_messages_from(user).count).to eq(1)
    end

    it 'should only find one thread with multiple messages from the same user' do
      message
      FactoryGirl.create(:message, thread: thread, created_by: user) # second message in same thread
      expect(MessageThread.with_messages_from(user).count).to eq(1)
    end
  end

  describe 'upcoming deadlines' do
    let(:thread) { FactoryGirl.create(:message_thread) }
    let(:deadline_message_old) { FactoryGirl.create(:deadline_message, message: FactoryGirl.create(:message, thread: thread), deadline: Time.now - 10.days) }
    let(:deadline_message_soon) { FactoryGirl.create(:deadline_message, message: FactoryGirl.create(:message, thread: thread), deadline: Time.now + 2.days) }
    let(:deadline_message_later) { FactoryGirl.create(:deadline_message, message: FactoryGirl.create(:message, thread: thread), deadline: Time.now + 100.days) }

    it 'should return one thread with upcoming deadlines' do
      deadline_message_soon
      deadline_message_later
      expect(MessageThread.with_upcoming_deadlines.count).to eq(1)
    end

    it 'should ingnore threads with old deadlines' do
      deadline_message_old
      expect(MessageThread.with_upcoming_deadlines.count).to eq(0)
    end

    it 'should return deadline messages in order' do
      deadline_message_old
      deadline_message_later
      deadline_message_soon
      messages = thread.upcoming_deadline_messages
      expect(messages.count).to eq(2)
      expect(messages.first).to eq(deadline_message_soon.message)
    end
  end

  describe '.order_by_latest_message' do
    it 'should return threads with most recent messages first' do
      threads = FactoryGirl.create_list(:message_thread, 3, :with_messages)
      found = MessageThread.order_by_latest_message
      expect(found).to eq(threads.reverse)
      expect(found.first.latest_message.created_at).to be > found.last.latest_message.created_at
    end
  end

  context 'public token' do
    it 'should be set after being created' do
      thread = FactoryGirl.create(:message_thread)
      expect(thread.public_token).to be_truthy
    end

    it 'should be a 10 digit alphanumeric string' do
      thread = FactoryGirl.create(:message_thread)
      expect(thread.public_token).to match(/\A[0-9a-f]{20}\Z/)
    end

    it 'should be set by set_public_token' do
      thread = FactoryGirl.create(:message_thread)
      thread.public_token = ''
      expect(thread.public_token).to be_blank
      thread.set_public_token
      expect(thread.public_token).not_to be_blank
    end
  end

  describe '#add_message_from_email!' do
    let(:mail) { FactoryGirl.create(:inbound_mail) }
    let(:thread) { FactoryGirl.create(:message_thread_with_messages) }

    it 'should create a new message' do
      messages = thread.add_messages_from_email!(mail)
      expect(messages.size).to eq(1)
      expect(messages.first).to be_a(Message)
      expect(messages.first.body).not_to be_blank
    end

    it 'should create a message with the user info' do
      message = thread.add_messages_from_email!(mail).first
      expect(message.created_by.name).to eq(mail.message.header[:from].display_names.first)
      expect(message.created_by.email).to eq(mail.message.header[:from].addresses.first)
    end

    context 'signature removal' do
      it 'should remove double-dash signatures' do
        allow(mail.message).to receive(:decoded).and_return("Normal text here\n\n--\nSignature")
        message = thread.add_messages_from_email!(mail).first
        expect(message.body).to eq("Normal text here\n")
      end
    end

    context 'with attachments' do
      let(:mail) { FactoryGirl.create(:inbound_mail, :with_attached_image) }

      it 'should create two messages' do
        messages = thread.add_messages_from_email!(mail)
        expect(messages.size).to eq(2)
        expect(messages[0]).to be_a(Message)
        expect(messages[1].component).to be_a(PhotoMessage)
      end
    end
  end

  describe '#first_message' do
    let(:thread) { FactoryGirl.create(:message_thread_with_messages) }

    it 'should return the oldest message on the thread' do
      expect(thread.first_message).to eq(thread.messages.order('created_at').first)
    end
  end

  describe 'messages text' do
    let(:thread) { FactoryGirl.create(:message_thread_with_messages) }

    it 'should return the text from all the messages' do
      thread.messages.each do |m|
        expect(thread.messages_text).to include(m.searchable_text)
      end
    end
  end
end
