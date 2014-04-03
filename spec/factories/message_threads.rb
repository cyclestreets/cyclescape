# == Schema Information
#
# Table name: message_threads
#
#  id            :integer          not null, primary key
#  issue_id      :integer
#  created_by_id :integer          not null
#  group_id      :integer
#  title         :string(255)      not null
#  privacy       :string(255)      not null
#  state         :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  public_token  :string(255)
#
# Indexes
#
#  index_message_threads_on_created_by_id  (created_by_id)
#  index_message_threads_on_group_id       (group_id)
#  index_message_threads_on_issue_id       (issue_id)
#  index_message_threads_on_public_token   (public_token) UNIQUE
#

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
