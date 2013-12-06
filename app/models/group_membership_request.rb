# == Schema Information
#
# Table name: group_membership_requests
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  group_id       :integer          not null
#  status         :string(255)      not null
#  actioned_by_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  message        :text
#

class GroupMembershipRequest < ActiveRecord::Base
  attr_protected :state_event

  belongs_to :group
  belongs_to :user
  belongs_to :actioned_by, class_name: "User"

  validates :user, presence: true
  validates :group, presence: true

  state_machine :status, :initial => :pending do
    before_transition any => :confirmed do |request|
      request.create_membership
    end

    state :pending, :cancelled

    state :confirmed, :rejected do
      validates :actioned_by, presence: true
    end

    event :confirm do
      transition :pending => :confirmed
    end

    event :reject do
      transition :pending => :rejected
    end

    event :cancel do
      transition :pending => :cancelled
    end
  end

  def initalize
    super
  end

  def create_membership
    membership = group.memberships.new
    membership.user = user
    membership.role = "member"
    membership.save!
  end
end
