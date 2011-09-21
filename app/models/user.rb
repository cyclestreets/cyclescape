class User < ActiveRecord::Base
  has_many :memberships, class_name: "GroupMembership"
  has_many :groups, through: :memberships
  has_many :issues, foreign_key: "created_by_id"
  has_many :created_threads, class_name: "MessageThread", foreign_key: "created_by_id"
  has_many :messages, foreign_key: "created_by_id"
end
