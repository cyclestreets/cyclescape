class GroupMembershipRequest < ActiveRecord::Base
  ALLOWED_STATUS = %w(pending confirmed rejected cancelled)

  belongs_to :group
  belongs_to :user
  belongs_to :actioned_by, class_name: "User"

  validates_associated :user
  validates_associated :group
  validates :status, inclusion: {in: ALLOWED_STATUS}
end
