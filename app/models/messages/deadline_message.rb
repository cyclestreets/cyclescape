# == Schema Information
#
# Table name: deadline_messages
#
#  id                :integer          not null, primary key
#  thread_id         :integer          not null
#  message_id        :integer          not null
#  created_by_id     :integer          not null
#  deadline          :datetime         not null
#  title             :string(255)      not null
#  created_at        :datetime
#  invalidated_at    :datetime
#  invalidated_by_id :integer
#

class DeadlineMessage < MessageComponent
  attr_accessible :deadline, :title

  validates :deadline, presence: true
  validates :title, presence: true
end
