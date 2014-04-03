# == Schema Information
#
# Table name: user_thread_priorities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  thread_id  :integer          not null
#  priority   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_thread_priorities_on_thread_id  (thread_id)
#  index_user_thread_priorities_on_user_id    (user_id)
#

FactoryGirl.define do
  factory :user_thread_priority do
    association :thread, factory: :message_thread
    user

    priority 10
  end
end
