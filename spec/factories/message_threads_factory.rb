# frozen_string_literal: true

FactoryBot.define do
  factory :message_thread do
    sequence(:title) { |n| "Message Thread #{n}" }
    privacy { "public" }
    status { "approved" }

    trait :belongs_to_group do
      group
    end

    trait :private do
      privacy { "group" }
    end

    trait :committee do
      created_by do
        FactoryBot.create(:group_membership, :committee, group: group).user
      end
      privacy { "committee" }
    end

    trait :belongs_to_issue do
      issue
    end

    trait :with_messages do
      after(:create) do |mt|
        user = FactoryBot.create(:user) # To prevent creating 1 user per message
        FactoryBot.create_list(:message, 2, thread: mt, created_by: user)
        mt.reload
      end
    end

    trait :with_tags do
      tags { FactoryBot.build_list(:tag, 2) }
    end

    trait :approved do
      status { :mod_queued }
      after(:create, &:approve!)
    end

    created_by do
      if group
        FactoryBot.create(:group_membership, :committee, group: group).user
      else
        FactoryBot.create(:user)
      end
    end

    factory :group_message_thread, traits: [:belongs_to_group]
    factory :issue_message_thread, traits: [:belongs_to_issue]
    factory :group_private_message_thread, traits: %i[belongs_to_group private]
    factory :group_private_message_thread_with_messages, traits: %i[belongs_to_group private with_messages]
    factory :group_committee_message_thread, traits: %i[belongs_to_group committee]
    factory :message_thread_with_messages, traits: [:with_messages]
  end
end
