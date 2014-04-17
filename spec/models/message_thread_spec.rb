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
    it { should belong_to(:created_by) }
    it { should belong_to(:group) }
    it { should belong_to(:issue) }
    it { should have_many(:messages) }
    it { should have_many(:subscriptions) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:created_by_id) }
    it { should allow_value('public').for(:privacy) }
    it { should allow_value('group').for(:privacy) }
    it { should allow_value('committee').for(:privacy) }
    it { should_not allow_value('other').for(:privacy) }
  end

  describe 'privacy' do
    subject { MessageThread.new }

    it 'should become private to group' do
      subject.should_not be_private_to_group
      subject.group = FactoryGirl.create(:group)
      subject.privacy = 'group'
      subject.should be_private_to_group
      subject.should_not be_private_to_committee
      subject.should_not be_public
    end

    it 'should become private to committee' do
      subject.should_not be_private_to_committee
      subject.group = FactoryGirl.create(:group)
      subject.privacy = 'committee'
      subject.should be_private_to_committee
      subject.should_not be_private_to_group
      subject.should_not be_public
    end

    it 'should be public' do
      subject.should_not be_public
      subject.privacy = 'public'
      subject.should be_public
    end
  end

  describe 'participants' do
    it 'should have zero participants' do
      thread = FactoryGirl.create(:message_thread)
      thread.participants.count.should == 0
    end

    it 'should have one participant' do
      thread = FactoryGirl.create(:message_thread_with_messages)
      thread.participants.count.should == 1
    end
  end

  describe 'priorities' do
    let(:user) { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }
    let!(:priority) { FactoryGirl.create(:user_thread_priority, user: user, thread: thread) }

    it 'should confirm that user has prioritised' do
      thread.priority_for(user).should == priority
    end
  end

  describe 'with messages from' do
    let(:user) { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }
    let(:message) { FactoryGirl.create(:message, thread: thread, created_by: user) }

    it 'should be empty' do
      MessageThread.with_messages_from(user).should be_empty
    end

    it 'should find one thread' do
      message
      MessageThread.with_messages_from(user).count.should == 1
    end

    it 'should only find one thread with multiple messages from the same user' do
      message
      FactoryGirl.create(:message, thread: thread, created_by: user) # second message in same thread
      MessageThread.with_messages_from(user).count.should == 1
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
      MessageThread.with_upcoming_deadlines.count.should == 1
    end

    it 'should ingnore threads with old deadlines' do
      deadline_message_old
      MessageThread.with_upcoming_deadlines.count.should == 0
    end

    it 'should return deadline messages in order' do
      deadline_message_old
      deadline_message_later
      deadline_message_soon
      messages = thread.upcoming_deadline_messages
      messages.count.should == 2
      messages.first.should == deadline_message_soon.message
    end
  end

  describe '.order_by_latest_message' do
    it 'should return threads with most recent messages first' do
      threads = FactoryGirl.create_list(:message_thread, 3, :with_messages)
      found = MessageThread.order_by_latest_message
      found.should == threads.reverse
      found.first.latest_message.created_at.should > found.last.latest_message.created_at
    end
  end

  context 'public token' do
    it 'should be set after being created' do
      thread = FactoryGirl.create(:message_thread)
      thread.public_token.should be_true
    end

    it 'should be a 10 digit alphanumeric string' do
      thread = FactoryGirl.create(:message_thread)
      thread.public_token.should match(/\A[0-9a-f]{20}\Z/)
    end

    it 'should be set by set_public_token' do
      thread = FactoryGirl.create(:message_thread)
      thread.public_token = ''
      thread.public_token.should be_blank
      thread.set_public_token
      thread.public_token.should_not be_blank
    end
  end

  describe '#add_message_from_email!' do
    let(:mail) { FactoryGirl.create(:inbound_mail) }
    let(:thread) { FactoryGirl.create(:message_thread_with_messages) }

    it 'should create a new message' do
      messages = thread.add_messages_from_email!(mail)
      messages.should have(1).item
      messages.first.should be_a(Message)
      messages.first.body.should_not be_blank
    end

    it 'should create a message with the user info' do
      message = thread.add_messages_from_email!(mail).first
      message.created_by.name.should == mail.message.header[:from].display_names.first
      message.created_by.email.should == mail.message.header[:from].addresses.first
    end

    context 'signature removal' do
      it 'should remove double-dash signatures' do
        mail.message.stub(:decoded).and_return("Normal text here\n\n--\nSignature")
        message = thread.add_messages_from_email!(mail).first
        message.body.should == "Normal text here\n"
      end
    end

    context 'with attachments' do
      let(:mail) { FactoryGirl.create(:inbound_mail, :with_attached_image) }

      it 'should create two messages' do
        messages = thread.add_messages_from_email!(mail)
        messages.should have(2).items
        messages[0].should be_a(Message)
        messages[1].component.should be_a(PhotoMessage)
      end
    end
  end

  describe '#first_message' do
    let(:thread) { FactoryGirl.create(:message_thread_with_messages) }

    it 'should return the oldest message on the thread' do
      thread.first_message.should == thread.messages.order('created_at').first
    end
  end

  describe 'messages text' do
    let(:thread) { FactoryGirl.create(:message_thread_with_messages) }

    it 'should return the text from all the messages' do
      thread.messages.each do |m|
        thread.messages_text.should include(m.searchable_text)
      end
    end
  end
end
