# frozen_string_literal: true

FactoryBot.define do
  factory :thread_leader_message do
    association :created_by, factory: :user
    association :message, factory: :message, strategy: :build
    description { "I lead" }

    after(:build) do |o|
      o.thread = o.message.thread
      o.message.thread_leader_messages = [o]
    end
  end
end
