# == Schema Information
#
# Table name: thread_subscriptions
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  thread_id  :integer         not null
#  created_at :datetime        not null
#  deleted_at :datetime
#

require 'spec_helper'

describe ThreadSubscription do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:thread) }
  end
end
