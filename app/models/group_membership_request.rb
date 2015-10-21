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
# Indexes
#
#  index_group_membership_requests_on_group_id  (group_id)
#  index_group_membership_requests_on_user_id   (user_id)
#

class GroupMembershipRequest < ActiveRecord::Base
  include AASM

  belongs_to :group
  belongs_to :user
  belongs_to :actioned_by, class_name: 'User'

  validates :user, presence: true
  validates :group, presence: true

  aasm column: 'status' do

    state :pending, initial: true
    state :confirmed, before_enter: :create_membership
    state :rejected
    state :cancelled

    event :confirm do
      transitions from: :pending, to: :confirmed, guard: :actioned_by
    end

    event :reject do
      transitions from: :pending, to: :rejected, guard: :actioned_by
    end

    event :cancel do
      transitions from: :pending, to: :cancelled
    end
  end

  def create_membership
    membership = group.memberships.new
    membership.user = user
    membership.role = 'member'
    membership.save!
  end
end
