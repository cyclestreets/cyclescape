FactoryGirl.define do
  factory :user_thread_priority do
    association :thread, factory: :message_thread
    user

    priority 10
  end
end
