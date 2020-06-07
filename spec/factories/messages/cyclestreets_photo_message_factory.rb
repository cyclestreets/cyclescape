# frozen_string_literal: true

FactoryBot.define do
  factory :cyclestreets_photo_message do
    association :created_by, factory: :user
    association :message, factory: :message, strategy: :build
    sequence(:caption) { |n| "Imaginative photo caption #{n}" }
    location { "POINT(-122 47)" }
    sequence(:photo_uid) { |n| "uid-#{n}" }
    photo { Pathname.new(test_photo_path) }

    after(:build) do |o|
      o.thread = o.message.thread
      o.message.cyclestreets_photo_messages << o
    end
  end
end
