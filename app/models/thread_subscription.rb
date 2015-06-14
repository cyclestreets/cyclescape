# == Schema Information
#
# Table name: thread_subscriptions
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  thread_id  :integer          not null
#  created_at :datetime         not null
#  deleted_at :datetime
#
# Indexes
#
#  index_thread_subscriptions_on_thread_id  (thread_id)
#  index_thread_subscriptions_on_user_id    (user_id)
#

class ThreadSubscription < ActiveRecord::Base
  include FakeDestroy

  belongs_to :user
  belongs_to :thread, class_name: 'MessageThread'
end
