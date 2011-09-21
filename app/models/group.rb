class Group < ActiveRecord::Base
  has_many :memberships, class_name: "GroupMembership"
  has_many :members, through: :memberships
  has_many :threads, class_name: "MessageThread"
end
