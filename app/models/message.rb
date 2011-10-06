# == Schema Information
#
# Table name: messages
#
#  id             :integer         not null, primary key
#  created_by_id  :integer         not null
#  thread_id      :integer         not null
#  body           :text            not null
#  component_id   :integer
#  component_type :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  deleted_at     :datetime
#

class Message < ActiveRecord::Base
  belongs_to :thread, class_name: "MessageThread"
  belongs_to :created_by, class_name: "User"

  validates :created_by_id, :body, presence: true
end
