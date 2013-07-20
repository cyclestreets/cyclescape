# == Schema Information
#
# Table name: document_messages
#
#  id            :integer          not null, primary key
#  thread_id     :integer          not null
#  message_id    :integer          not null
#  created_by_id :integer          not null
#  title         :string(255)      not null
#  file_uid      :string(255)
#  file_name     :string(255)
#  file_size     :integer
#

require "spec_helper"

describe DocumentMessage do
  describe "associations" do
    it { should belong_to(:message) }
    it { should belong_to(:thread) }
    it { should belong_to(:created_by) }
  end

  describe "validations" do
    it { should validate_presence_of(:file) }
    it { should validate_presence_of(:title) }
  end

  context "factory" do
    subject { FactoryGirl.create(:document_message) }

    it { should be_valid }

    it "should have a thread" do
      subject.thread.should be_a(MessageThread)
    end

    it "should have a message" do
      subject.message.should be_a(Message)
    end
  end
end
