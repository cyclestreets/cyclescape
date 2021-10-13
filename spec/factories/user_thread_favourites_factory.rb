# frozen_string_literal: true

FactoryBot.define do
  factory :user_thread_favourite do
    association :thread, factory: :message_thread
    user
  end
end
