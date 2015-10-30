# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  full_name              :string(255)      not null
#  display_name           :string(255)
#  role                   :string(255)      not null
#  encrypted_password     :string(128)      default("")
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  disabled_at            :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invitation_token       :string(255)
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  remembered_group_id    :integer
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#  deleted_at             :datetime
#  invitation_created_at  :datetime
#
# Indexes
#
#  index_users_on_email             (email)
#  index_users_on_invitation_token  (invitation_token)
#

class User < ActiveRecord::Base

  acts_as_voter
  acts_as_paranoid

  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :validatable, :invitable
  ALLOWED_ROLES = %w(member admin)

  has_many :memberships, class_name: 'GroupMembership'
  has_many :groups, through: :memberships
  has_many :membership_requests, class_name: 'GroupMembershipRequest'
  has_many :actioned_membership_requests, foreign_key: 'actioned_by_id', class_name: 'GroupMembershipRequest'
  has_many :issues, foreign_key: 'created_by_id'
  has_many :created_threads, class_name: 'MessageThread', foreign_key: 'created_by_id'
  has_many :messages, foreign_key: 'created_by_id'
  has_many :locations, class_name: 'UserLocation'
  has_many :thread_subscriptions do
    def to(thread)
      where('thread_id = ?', thread).first
    end
  end
  # Would be better using the 'active' named scope on thread_subscriptions instead of the conditions block. But how?
  has_many :subscribed_threads, -> { where('thread_subscriptions.deleted_at is NULL') },
    through: :thread_subscriptions, source: :thread
  has_many :thread_priorities, class_name: 'UserThreadPriority'
  has_many :prioritised_threads, through: :thread_priorities, source: :thread
  has_many :thread_views
  has_many :site_comments
  has_one :profile, class_name: 'UserProfile'
  has_one :prefs, class_name: 'UserPref'
  belongs_to :remembered_group, class_name: 'Group'

  accepts_nested_attributes_for :profile, update_only: true

  before_validation :set_default_role, unless: :role
  after_create :create_user_prefs

  before_destroy :obfuscate_name
  before_destroy :clear_profile
  before_destroy :remove_locations
  before_destroy :remove_group_memberships
  before_destroy :remove_thread_subscriptions

  scope :active, -> { where('"users".disabled_at IS NULL AND "users".confirmed_at IS NOT NULL AND "users".deleted_at IS NULL') }
  scope :admin,  -> { where(role: 'admin') }
  scope :is_public, -> { joins(:profile).where(user_profiles: {visibility: 'public'}) }

  validates :full_name, presence: true
  validates :display_name, uniqueness: true, allow_blank: true
  validates :role, presence: true, inclusion: { in: ALLOWED_ROLES }

  def self.user_roles_map
    ALLOWED_ROLES.map { |n| [I18n.t("user_roles.#{n.to_s}"), n] }
  end

  def self.find_or_invite(email_address, name = nil)
    existing = find_by_email(email_address)
    return existing if existing
    name = email_address.split('@').first if name.nil?
    User.invite!(full_name: name, email: email_address)
  end

  def self.init_user_prefs
    joins('LEFT OUTER JOIN user_prefs ON user_prefs.user_id = users.id').
      where('user_prefs.id IS NULL').
      each { |u| u.create_user_prefs }
  end

  def approve!
    update approved: true
  end

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
    thread_subscriptions.active.to(thread)
  end

  def ever_subscribed_to_thread?(thread)
    thread_subscriptions.to(thread)
  end

  def involved_threads
    MessageThread.with_messages_from(self)
  end

  def prioritised_thread?(thread)
    thread_priorities.where(thread_id: thread.id).exists?
  end

  def viewed_thread?(thread)
    thread_views.where(thread_id: thread.id).exists?
  end

  def viewed_thread_at(thread)
    thread_views.where(thread_id: thread.id).first.viewed_at
  end

  def disabled
    disabled_at?
  end

  def disabled=(d)
    if d == '1' && !disabled_at?
      self.disabled_at = Time.zone.now
    end
    if d == '0' && disabled_at?
      self.disabled_at = nil
    end
  end

  def buffered_locations
    locations.map { |l| l.location.buffer(Geo::USER_LOCATIONS_BUFFER) }.inject { |geo, item| geo.union(item) }
  end

  # Returns issues that are within a small distance of their user_locations
  def issues_near_locations
    Issue.intersects(buffered_locations)
  end

  def planning_applications_near_locations
    PlanningApplication.intersects(buffered_locations)
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

  def create_user_prefs
    build_prefs.save!
  end

  def membership_request_pending_for?(group)
    return membership_requests.where(group_id: group.id, status: :pending).count > 0
  end

  def update_remembered_group(group)
    # Not using association to avoid validation checks
    new_id = group ? group.id : nil
    update_column(:remembered_group_id, new_id) unless remembered_group_id == new_id
  end

  def remembered_group?
    remembered_group
  end

  def obfuscate_name
    self.full_name = "User #{id} (deleted)"
    self.display_name = nil
    true
  end

  def display_name_or_anon
    display_name || I18n.t('anon')
  end

  def clear_profile
    profile.clear
    true
  end

  def remove_locations
    locations.each(&:destroy)
    true
  end

  def remove_group_memberships
    memberships.each(&:destroy)
    true
  end

  def remove_thread_subscriptions
    thread_subscriptions.each(&:destroy)
    true
  end

  def can_view(other_users)
    viewable_by_public_ids = other_users.is_public.pluck :id

    my_group_ids = groups.pluck :id

    in_my_groups = other_users.joins(:memberships).where(group_memberships: {group_id: my_group_ids}).pluck :id

    self.class.where id: (in_my_groups + viewable_by_public_ids + [id]).compact
  end

  protected

  def set_default_role
    self.role = 'member'
  end

  # Devise hook for password validation
  def password_required?
    !invitation_token.present? && super
  end
end
