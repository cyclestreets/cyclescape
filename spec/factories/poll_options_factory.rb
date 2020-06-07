# frozen_string_literal: true

FactoryBot.define do
  factory :poll_option do
    association :poll_message, factory: :poll_message
    sequence(:option) { |n| "Option #{n}" }
  end
end
