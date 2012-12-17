class ThreadView < ActiveRecord::Base
  belongs_to :user
  belongs_to :thread, class_name: "MessageThread"
end
