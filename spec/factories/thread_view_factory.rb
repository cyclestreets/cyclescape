FactoryBot.define do
  factory :thread_view do
    association :thread, factory: :message_thread
    user

    viewed_at Time.now
  end
end
