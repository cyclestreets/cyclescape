# == Schema Information
#
# Table name: thread_subscriptions
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  thread_id  :integer         not null
#  created_at :datetime        not null
#  deleted_at :datetime
#  send_email :boolean         default(FALSE), not null
#

class ThreadSubscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :thread, class_name: "MessageThread"
end
