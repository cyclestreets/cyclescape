class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :validatable, :invitable
  ALLOWED_ROLES = %w(member admin)

  has_many :memberships, class_name: "GroupMembership"
  has_many :groups, through: :memberships
  has_many :issues, foreign_key: "created_by_id"
  has_many :created_threads, class_name: "MessageThread", foreign_key: "created_by_id"
  has_many :messages, foreign_key: "created_by_id"

  before_validation :set_default_role, :unless => :role

  validates :full_name, presence: true
  validates :role, presence: true, inclusion: {in: ALLOWED_ROLES} 

  def name
    return display_name unless display_name.blank?
    full_name
  end

  def role_symbols
    [role.to_sym]
  end

  private

  def set_default_role
    self.role = "member"
  end

  # Devise hook for password validation
  def password_required?
    !invitation_token.present? && super
  end
end
