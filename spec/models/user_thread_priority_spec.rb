require 'spec_helper'

describe UserThreadPriority do
  let(:subect) { FactoryGirl.create(:user_thread_priority) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:thread) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:priority).in_range(1..10) }
  end
end
