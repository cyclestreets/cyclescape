class UserThreadPriority < ActiveRecord::Base

  belongs_to :user
  belongs_to :thread, class_name: "MessageThread"

  validates :priority, inclusion: 1..10
  validates :user, presence: true
  validates :thread, presence: true
end
