# frozen_string_literal: true

FactoryBot.define do
  factory :street_view_message do
    association :created_by, factory: :user
    association :message, factory: :message, strategy: :build
    sequence(:caption) { |n| "Imaginative street view caption #{n}" }
    location { "POINT(-122 47)" }
    heading { 10.1 }
    pitch { 0.1 }

    after(:build) do |o|
      o.thread = o.message.thread
      o.message.street_view_messages << o
    end
  end
end

