# == Schema Information
#
# Table name: thread_subscriptions
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  thread_id  :integer         not null
#  created_at :datetime        not null
#  deleted_at :datetime
#

class ThreadSubscription < ActiveRecord::Base
  include FakeDestroy

  belongs_to :user
  belongs_to :thread, class_name: "MessageThread"
end
