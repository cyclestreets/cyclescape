# frozen_string_literal: true



FactoryBot.define do
  factory :thread_view do
    association :thread, factory: :message_thread
    user

    viewed_at { Time.now.in_time_zone }
  end
end

# == Schema Information
#
# Table name: thread_views
#
#  id        :integer          not null, primary key
#  viewed_at :datetime         not null
#  thread_id :integer          not null
#  user_id   :integer          not null
#
# Indexes
#
#  index_thread_views_on_user_id                (user_id)
#  index_thread_views_on_user_id_and_thread_id  (user_id,thread_id) UNIQUE
#
