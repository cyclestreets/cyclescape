class Message < ActiveRecord::Base
  belongs_to :thread, class_name: "MessageThread"
  belongs_to :created_by, class_name: "User"
end
