# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  full_name              :string(255)     not null
#  display_name           :string(255)
#  role                   :string(255)     not null
#  encrypted_password     :string(128)     default("")
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  disabled_at            :datetime
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  invitation_token       :string(60)
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#

class User < ActiveRecord::Base

  acts_as_voter

  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :validatable, :invitable
  ALLOWED_ROLES = %w(member admin)

  has_many :memberships, class_name: "GroupMembership"
  has_many :groups, through: :memberships
  has_many :membership_requests, class_name: "GroupMembershipRequest"
  has_many :actioned_membership_requests, foreign_key: "actioned_by_id", class_name: "GroupMembershipRequest"
  has_many :issues, foreign_key: "created_by_id"
  has_many :created_threads, class_name: "MessageThread", foreign_key: "created_by_id"
  has_many :messages, foreign_key: "created_by_id"
  has_many :locations, class_name: "UserLocation"
  has_many :thread_subscriptions, conditions: {deleted_at: nil} do
    def to(thread)
      where("thread_id = ?", thread).first
    end
  end
  has_many :subscribed_threads, through: :thread_subscriptions, source: :thread
  has_one :profile, class_name: "UserProfile"
  accepts_nested_attributes_for :profile, update_only: true

  before_validation :set_default_role, :unless => :role

  validates :full_name, presence: true
  validates :role, presence: true, inclusion: {in: ALLOWED_ROLES} 

  def name
    return display_name unless display_name.blank?
    full_name
  end

  def name_with_email
    "#{name} <#{email}>"
  end

  def role_symbols
    return [:root] if root?
    [role.to_sym]
  end

  def root?
    id == 1
  end

  def profile_with_auto_build
    profile_without_auto_build || build_profile
  end
  alias_method_chain :profile, :auto_build

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def subscribed_to_thread?(thread)
    thread_subscriptions.where("thread_id = ?", thread).exists?
  end

  def involved_threads
    MessageThread.with_messages_from(self)
  end

  def disabled
    disabled_at?
  end

  def disabled=(d)
    if d == "1" && !disabled_at?
      self.disabled_at = Time.now
    end
    if d == "0" && disabled_at?
      self.disabled_at = nil
    end
  end

  def buffered_locations
    locations.map{ |l| l.location.buffer(Geo::USER_LOCATIONS_BUFFER) }.inject{ |geo, item| geo.union(item) }
  end

  # Returns issues that are within a small distance of their user_locations
  def issues_near_locations
    Issue.intersects(buffered_locations)
  end

  def start_location
    # Figure out a suitable starting location for the user, e.g. for adding new issues.

    # First, the latest find a "primary" or "home" location.
    l = locations.where(category_id: LocationCategory.first).last
    return l.location unless l.blank?

    # If not, take the latest location they have.
    l = locations.last
    return l.location unless l.blank?

    # Figure out the group from the subdomain, and use that if possible
    # group = <enter some code here>
    # return group.profile.location if group.profile.location

    # Take the location from the first of their groups that has a location
    groups.each do |g|
      return g.profile.location if g.profile.location
    end

    # Give up
    return Geo::NOWHERE_IN_PARTICULAR
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
