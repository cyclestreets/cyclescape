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

require 'spec_helper'

describe DocumentMessage do
  describe 'associations' do
    it { is_expected.to belong_to(:message) }
    it { is_expected.to belong_to(:thread) }
    it { is_expected.to belong_to(:created_by) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:file) }
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'factory' do
    subject { create(:document_message) }

    it { is_expected.to be_valid }

    it 'should have a thread' do
      expect(subject.thread).to be_a(MessageThread)
    end

    it 'should have a message' do
      expect(subject.message).to be_a(Message)
    end
  end
end
