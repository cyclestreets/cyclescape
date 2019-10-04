# frozen_string_literal: true

FactoryBot.define do
  factory :photo_message do
    association :created_by, factory: :user
    association :message, factory: :message, strategy: :build
    sequence(:caption) { |n| "Imaginative photo caption #{n}" }
    photo { Pathname.new(test_photo_path) }

    after(:build) do |o|
      o.thread = o.message.thread
      o.message.photo_messages = [o]
    end

    factory :photo_message_with_description do
      sequence(:description) { |n| "This photo shows #{n} bottles of beer." }
    end
  end
end
