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
  has_many :membership_requests, class_name: "GroupMembershipRequest"
  has_many :threads, class_name: "MessageThread"
  has_one :profile, class_name: "GroupProfile"

  validates :name, :short_name, presence: true

  after_create :create_default_profile, unless: :profile

  def committee_members
    members.where("group_memberships.role = 'committee'")
  end

  def normal_members
    members.where("group_memberships.role = 'member'")
  end

  def recent_issues
    Issue.intersects(profile.location).order("created_at DESC")
  end

  def to_param
    "#{id}-#{short_name}"
  end

  protected

  def create_default_profile
    build_profile.save!
  end
end
