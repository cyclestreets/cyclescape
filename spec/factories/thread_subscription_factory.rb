# frozen_string_literal: true



FactoryBot.define do
  factory :thread_subscription do
    user
    association :thread, factory: :message_thread
  end
end

# == Schema Information
#
# Table name: thread_subscriptions
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  thread_id  :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_thread_subscriptions_on_thread_id              (thread_id)
#  index_thread_subscriptions_on_thread_id_and_user_id  (thread_id,user_id) UNIQUE WHERE (deleted_at IS NULL)
#  index_thread_subscriptions_on_user_id                (user_id)
#
