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
  include FakeDestroy

  belongs_to :thread, class_name: "MessageThread"
  belongs_to :created_by, class_name: "User"
  belongs_to :component, polymorphic: true, autosave: true

  scope :recent, order("created_at DESC").limit(3)

  validates :created_by_id, presence: true
  validates :body, presence: true, unless: :component
end
