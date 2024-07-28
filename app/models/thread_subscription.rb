# frozen_string_literal: true

class ThreadSubscription < ApplicationRecord
  include FakeDestroy

  belongs_to :user
  belongs_to :thread, class_name: "MessageThread", inverse_of: :subscriptions

  before_destroy :remove_leader

  private

  def remove_leader
    user.thread_leader_messages.where(thread: thread).destroy_all
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
