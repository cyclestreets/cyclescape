# == Schema Information
#
# Table name: messages
#
#  id             :integer         not null, primary key
#  created_by_id  :integer         not null
#  thread_id      :integer         not null
#  body           :text            not null
#  component_id   :integer
#  component_type :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  deleted_at     :datetime
#  censored_at    :datetime
#

FactoryGirl.define do
  factory :message do
    association :created_by, factory: :user
    association :thread, factory: :message_thread
    body "Meg: I just want to kill myself I'm gonna go upstairs and eat a whole bowl of peanuts."
  end
end
