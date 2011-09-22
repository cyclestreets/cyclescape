class GroupMembership < ActiveRecord::Base
  ALLOWED_ROLES = %w(committee member)

  belongs_to :group
  belongs_to :user

  validates :group_id, :user_id, presence: true
  validates :role, inclusion: {in: ALLOWED_ROLES}
end
