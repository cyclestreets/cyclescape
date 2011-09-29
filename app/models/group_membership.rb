class GroupMembership < ActiveRecord::Base
  ALLOWED_ROLES = %w(committee member)

  belongs_to :group
  belongs_to :user, autosave: true

  scope :committee, where("role = 'committee'")
  scope :normal, where("role = 'member'")

  before_validation :invite_user_if_new

  validates :group_id, presence: true
  validates :role, inclusion: {in: ALLOWED_ROLES}
  validates_associated :user

  accepts_nested_attributes_for :user

  def self.allowed_roles_map
    ALLOWED_ROLES.map {|r| [r.capitalize, r] }
  end

  def role=(val)
    write_attribute(:role, val.downcase)
  end

  protected

  def invite_user_if_new
    user && user.new_record? && user.invite!
    true
  end
end
