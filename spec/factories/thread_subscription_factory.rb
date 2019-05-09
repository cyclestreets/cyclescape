# frozen_string_literal: true

FactoryBot.define do
  factory :thread_subscription do
    user
    association :thread, factory: :message_thread
  end
end
