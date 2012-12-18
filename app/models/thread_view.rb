class ThreadView < ActiveRecord::Base
  belongs_to :user
  belongs_to :thread, class_name: "MessageThread"

  validates :user, presence: true
  validates :thread, presence: true
  validates :viewed_at, presence: true
end
