FactoryGirl.define do
  factory :library_item_message do
    association :created_by, factory: :user
    association :message, factory: :message

    after(:build) do |o|
      o.thread = o.message.thread
      o.message.update_columns(component: o)
    end

    trait :with_document do
      after(:build) do |o|
        doc = FactoryGirl.create(:library_document)
        o.item = doc.item
      end
    end

    factory :library_item_message_with_document, traits: [:with_document]
  end
end
