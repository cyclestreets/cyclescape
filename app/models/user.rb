class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :validatable
  ALLOWED_ROLES = %w(member admin)

  has_many :memberships, class_name: "GroupMembership"
  has_many :groups, through: :memberships
  has_many :issues, foreign_key: "created_by_id"
  has_many :created_threads, class_name: "MessageThread", foreign_key: "created_by_id"
  has_many :messages, foreign_key: "created_by_id"

  before_validation :set_default_role, :unless => :role

  validates :role, presence: true, inclusion: {in: ALLOWED_ROLES} 

  private

  def set_default_role
    self.role = "member"
  end
end
