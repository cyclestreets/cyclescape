# == Schema Information
#
# Table name: deadline_messages
#
#  id                :integer          not null, primary key
#  thread_id         :integer          not null
#  message_id        :integer          not null
#  created_by_id     :integer          not null
#  deadline          :datetime         not null
#  title             :string(255)      not null
#  created_at        :datetime
#  invalidated_at    :datetime
#  invalidated_by_id :integer
#

require 'spec_helper'

describe DeadlineMessage do
  describe 'associations' do
    it { is_expected.to belong_to(:thread) }
    it { is_expected.to belong_to(:message) }
    it { is_expected.to belong_to(:created_by) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:deadline) }
    it { is_expected.to validate_presence_of(:title) }
  end
end
