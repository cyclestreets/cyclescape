# == Schema Information
#
# Table name: user_thread_priorities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  thread_id  :integer          not null
#  priority   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserThreadPriority < ActiveRecord::Base
  attr_accessible :priority

  PRIORITIES = { very_high: 10,
                 high: 8,
                 medium: 6,
                 low: 3,
                 very_low: 1 }

  belongs_to :user
  belongs_to :thread, class_name: 'MessageThread'

  validates :priority, inclusion: 1..10
  validates :user, presence: true
  validates :thread, presence: true

  def self.priorities_map
    PRIORITIES.map { |p, v| [I18n.t(".thread_priorities.#{p.to_s}"), v] }
  end

  def label
    PRIORITIES.key(priority)
  end
end
