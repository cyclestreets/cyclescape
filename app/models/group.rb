class Group < ActiveRecord::Base
  has_many :memberships, class_name: "GroupMembership"
  has_many :members, through: :memberships, source: :user
  has_many :threads, class_name: "MessageThread"

  validates :name, :short_name, presence: true

  def to_param
    "#{id}-#{short_name}"
  end
end
