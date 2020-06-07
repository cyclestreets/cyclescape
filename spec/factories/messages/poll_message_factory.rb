# frozen_string_literal: true

FactoryBot.define do
  factory :poll_message do
    association :created_by, factory: :user
    association :message, factory: :message, strategy: :build
    question { "Why oh why?" }

    after(:build) do |po|
      po.thread = po.message.thread
      po.message.poll_messages << po
    end

    trait :with_options do
      transient do
        nos_options { 2 }
      end
      after(:build) do |poll_m, evaluator|
        poll_m.poll_options = FactoryBot.build_list(:poll_option, evaluator.nos_options, poll_message: poll_m)
      end
    end
  end
end
