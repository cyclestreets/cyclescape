# == Schema Information
#
# Table name: message_threads
#
#  id            :integer         not null, primary key
#  issue_id      :integer
#  created_by_id :integer         not null
#  group_id      :integer
#  title         :string(255)     not null
#  privacy       :string(255)     not null
#  state         :string(255)     not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

require 'spec_helper'

describe MessageThread do
  it_should_behave_like "a taggable model"

  describe "associations" do
    it { should belong_to(:created_by) }
    it { should belong_to(:group) }
    it { should belong_to(:issue) }
    it { should have_many(:messages) }
    it { should have_many(:subscriptions) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:created_by_id) }
    it { should allow_value("public").for(:privacy) }
    it { should allow_value("group").for(:privacy) }
    it { should_not allow_value("other").for(:privacy) }
  end

  describe "privacy" do
    subject { MessageThread.new }

    it "should become private to group" do
      subject.should_not be_private_to_group
      subject.group = FactoryGirl.create(:group)
      subject.privacy = "group"
      subject.should be_private_to_group
    end

    it "should be public" do
      subject.should_not be_public
      subject.privacy = "public"
      subject.should be_public
    end
  end

  describe "participants" do
    it "should have zero participants" do
      thread = FactoryGirl.create(:message_thread)
      thread.participants.count.should == 0
    end

    it "should have one participant" do
      thread = FactoryGirl.create(:message_thread_with_messages)
      thread.participants.count.should == 1
    end
  end

  describe "priorities" do
    let(:user) { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }
    let!(:priority) { FactoryGirl.create(:user_thread_priority, user: user, thread: thread) }

    it "should confirm that user has prioritised" do
      thread.priority_for(user).should == priority
    end
  end

  describe "with messages from" do
    let(:user) { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }
    let(:message) { FactoryGirl.create(:message, thread: thread, created_by: user) }

    it "should be empty" do
      MessageThread.with_messages_from(user).should be_empty
    end

    it "should find one thread" do
      message
      MessageThread.with_messages_from(user).count.should == 1
    end

    it "should only find one thread with multiple messages from the same user" do
      message
      message2 = FactoryGirl.create(:message, thread: thread, created_by: user)
      MessageThread.with_messages_from(user).count.should == 1
    end
  end

  context "public token" do
    it "should be set after being created" do
      thread = FactoryGirl.create(:message_thread)
      thread.public_token.should be_true
    end

    it "should be a 10 digit alphanumeric string" do
      thread = FactoryGirl.create(:message_thread)
      thread.public_token.should match(/\A[0-9a-f]{20}\Z/)
    end

    it "should be set by set_public_token" do
      thread = FactoryGirl.create(:message_thread)
      thread.public_token = ""
      thread.public_token.should be_blank
      thread.set_public_token
      thread.public_token.should_not be_blank
    end
  end
end
