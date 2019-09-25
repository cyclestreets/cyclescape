# frozen_string_literal: true

FactoryBot.define do
  factory :thread_leader_message do
    association :created_by, factory: :user
    association :message, factory: :message
    description { "I lead" }

    after(:build) do |o|
      o.thread = o.message.thread
    end
  end
end
