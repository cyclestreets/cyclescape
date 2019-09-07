# frozen_string_literal: true


class GroupMembershipRequest < ApplicationRecord
  include AASM

  belongs_to :group
  belongs_to :user
  belongs_to :actioned_by, class_name: "User"
  belongs_to :group_membership

  validates :user, presence: true
  validates :group, presence: true
  validates :user, uniqueness: { scope: :group_id }

  aasm column: "status" do
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
    return true if user.groups.include?(group)

    create_group_membership!(group: group, user: user, role: "member")
  end
end

# == Schema Information
#
# Table name: group_membership_requests
#
#  id                  :integer          not null, primary key
#  message             :text
#  status              :string(255)      not null
#  created_at          :datetime
#  updated_at          :datetime
#  actioned_by_id      :integer
#  group_id            :integer          not null
#  group_membership_id :integer
#  user_id             :integer          not null
#
# Indexes
#
#  index_group_membership_requests_on_actioned_by_id        (actioned_by_id)
#  index_group_membership_requests_on_group_id              (group_id)
#  index_group_membership_requests_on_group_membership_id   (group_membership_id)
#  index_group_membership_requests_on_user_id               (user_id)
#  index_group_membership_requests_on_user_id_and_group_id  (user_id,group_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (group_membership_id => group_memberships.id)
#
