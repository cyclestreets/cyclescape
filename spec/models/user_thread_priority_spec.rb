# == Schema Information
#
# Table name: user_thread_priorities
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  thread_id  :integer         not null
#  priority   :integer         not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe UserThreadPriority do
  let(:subect) { FactoryGirl.create(:user_thread_priority) }

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:thread) }
  end

  describe "validations" do
    it { should ensure_inclusion_of(:priority).in_range(1..10) }
  end
end
