class UserThreadPriority < ActiveRecord::Base
  PRIORITIES = { very_high: 10,
                 high: 8,
                 medium: 6,
                 low: 3,
                 very_low: 1 }

  belongs_to :user
  belongs_to :thread, class_name: "MessageThread"

  validates :priority, inclusion: 1..10
  validates :user, presence: true
  validates :thread, presence: true

  def self.priorities_map
    PRIORITIES.map {|p,v| [p.to_s.capitalize, v] }
  end
end
