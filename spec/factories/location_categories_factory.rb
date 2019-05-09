# frozen_string_literal: true

FactoryBot.define do
  factory :location_category do
    sequence(:name) { |n| "User location category #{n}" }
  end
end
