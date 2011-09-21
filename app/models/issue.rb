class Issue < ActiveRecord::Base
  belongs_to :created_by, class_name: "User"
  has_many :threads, class_name: "MessageThread"
end
