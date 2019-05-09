# frozen_string_literal: true

FactoryBot.define do
  factory :library_item_message do
    association :created_by, factory: :user
    message

    after(:build) do |o|
      o.thread = o.message.thread
      o.message.update(component: o)
    end

    trait :with_document do
      after(:build) do |o|
        doc = FactoryBot.create(:library_document)
        o.item = doc.item
      end
    end

    factory :library_item_message_with_document, traits: [:with_document]
  end
end
