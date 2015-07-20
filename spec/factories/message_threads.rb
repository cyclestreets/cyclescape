FactoryGirl.define do
  factory :message_thread do
    association :created_by, factory: :user
    sequence(:title) { |n| "Message Thread #{n}" }
    privacy 'public'

    trait :belongs_to_group do
      group
    end

    trait :private do
      privacy 'group'
    end

    trait :committee do
      privacy 'committee'
    end

    trait :belongs_to_issue do
      issue
    end

    trait :with_messages do
      after(:create) do |mt|
        user = FactoryGirl.create(:user)  # To prevent creating 1 user per message
        FactoryGirl.create_list(:message, 2, thread: mt, created_by: user)
        mt.reload
      end
    end

    trait :with_tags do
      tags { FactoryGirl.build_list(:tag, 2) }
    end

    factory :group_message_thread, traits: [:belongs_to_group]
    factory :issue_message_thread, traits: [:belongs_to_issue]
    factory :group_private_message_thread, traits: [:belongs_to_group, :private]
    factory :group_private_message_thread_with_messages, traits: [:belongs_to_group, :private, :with_messages]
    factory :group_committee_message_thread, traits: [:belongs_to_group, :committee]
    factory :message_thread_with_messages, traits: [:with_messages]
  end
end
