# == Schema Information
#
# Table name: message_threads
#
#  id            :integer         not null, primary key
#  issue_id      :integer
#  created_by_id :integer         not null
#  group_id      :integer
#  title         :string(255)     not null
#  description   :text            not null
#  privacy       :string(255)     not null
#  state         :string(255)     not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

FactoryGirl.define do
  factory :message_thread do
    association :created_by, factory: :user
    sequence(:title) {|n| "Message Thread #{n}" }
    description "Why are we discussing this?"
    privacy "public"

    trait :belongs_to_group do
      group
    end

    trait :private do
      privacy "group"
    end

    trait :belongs_to_issue do
      issue
    end

    trait :with_messages do
      after_create do |mt|
        user = FactoryGirl.create(:user)  # To prevent creating 1 user per message
        FactoryGirl.create_list(:message, 1 + Random.rand(4), thread: mt, created_by: user)
      end
    end

    factory :group_message_thread, traits: [:belongs_to_group]
    factory :issue_message_thread, traits: [:belongs_to_issue]
    factory :group_private_message_thread, traits: [:belongs_to_group, :private]
    factory :message_thread_with_messages, traits: [:with_messages]
  end
end
