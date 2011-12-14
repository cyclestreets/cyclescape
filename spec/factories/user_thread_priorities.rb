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

FactoryGirl.define do
  factory :user_thread_priority do
    association :thread, factory: :message_thread
    user

    priority 10
  end
end
