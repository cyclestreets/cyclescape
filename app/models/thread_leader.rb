class ThreadLeader < ActiveRecord::Base
  belongs_to :user
  belongs_to :message_thread

  delegate :subscribers, :closed, :leaders, to: :message_thread
end
