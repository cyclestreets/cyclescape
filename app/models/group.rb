# == Schema Information
#
# Table name: groups
#
#  id          :integer         not null, primary key
#  name        :string(255)     not null
#  short_name  :string(255)     not null
#  website     :string(255)
#  email       :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  disabled_at :datetime
#

class Group < ActiveRecord::Base
  has_many :memberships, class_name: "GroupMembership"
  has_many :members, through: :memberships, source: :user
  has_many :threads, class_name: "MessageThread"

  validates :name, :short_name, presence: true

  def committee_members
    members.where("group_memberships.role = 'committee'")
  end

  def normal_members
    members.where("group_memberships.role = 'member'")
  end

  def to_param
    "#{id}-#{short_name}"
  end
end
