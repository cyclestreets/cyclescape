# frozen_string_literal: true

FactoryBot.define do
  factory :thread_view do
    association :thread, factory: :message_thread
    user

    viewed_at Time.now.in_time_zone
  end
end
