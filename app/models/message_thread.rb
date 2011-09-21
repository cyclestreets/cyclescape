class MessageThread < ActiveRecord::Base
  belongs_to :created_by, class_name: "User"
  belongs_to :group
  belongs_to :issue
  has_many :messages
end
