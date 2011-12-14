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
