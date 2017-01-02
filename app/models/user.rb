class User < ActiveRecord::Base
  ALLOWED_ROLES = %w(member admin).freeze
  SEARCHABLE_COLUMNS = %w(full_name display_name email).freeze

  include Searchable

  acts_as_voter
  acts_as_paranoid

  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :validatable, :invitable

  has_many :memberships, class_name: 'GroupMembership', dependent: :destroy
  has_many :groups, through: :memberships
  has_many :membership_requests, class_name: 'GroupMembershipRequest', dependent: :destroy
  has_many :requested_groups, through: :membership_requests, source: :group
  has_many :actioned_membership_requests, foreign_key: 'actioned_by_id', class_name: 'GroupMembershipRequest'
  has_many :issues, foreign_key: 'created_by_id'
  has_many :created_threads, class_name: 'MessageThread', foreign_key: 'created_by_id'
  has_many :messages, foreign_key: 'created_by_id'
  has_many :locations, class_name: 'UserLocation', dependent: :destroy
  has_many :thread_subscriptions, dependent: :destroy do
    def to(thread)
      where('thread_id = ?', thread).order(deleted_at: :desc).first
    end
  end
  # Would be better using the 'active' named scope on thread_subscriptions instead of the conditions block. But how?
  has_many :subscribed_threads, -> { where('thread_subscriptions.deleted_at is NULL').merge(MessageThread.approved) },
    through: :thread_subscriptions, source: :thread
  has_many :thread_priorities, class_name: 'UserThreadPriority', inverse_of: :user
  has_many :prioritised_threads, through: :thread_priorities, source: :thread
  has_many :thread_views, inverse_of: :user
  has_many :site_comments
  has_many :private_threads, class_name: 'MessageThread', inverse_of: :user
  has_many :thread_leader_messages, -> { active }, dependent: :destroy, inverse_of: :created_by, foreign_key: :created_by_id
  has_many :leading_threads, through: :thread_leader_messages, source: :thread, inverse_of: :leaders
  has_one :profile, class_name: 'UserProfile'
  has_one :prefs, class_name: 'UserPref'
  belongs_to :remembered_group, class_name: 'Group'

  accepts_nested_attributes_for :profile, update_only: true

  before_validation :set_default_role, unless: :role
  after_create :create_user_prefs
  after_create :add_memberships
  before_create :set_public_token

  before_destroy :obfuscate_name
  before_destroy :clear_profile

  scope :active, -> { where('"users".disabled_at IS NULL AND "users".confirmed_at IS NOT NULL AND "users".deleted_at IS NULL') }
  scope :admin,  -> { where(role: 'admin') }
  scope :is_public, -> { joins(:profile).where(user_profiles: {visibility: 'public'}) }

  validates :full_name, presence: true, format: { without: /[\[\]]/ }
  validates :display_name, uniqueness: true, allow_nil: true
  validates :role, presence: true, inclusion: { in: ALLOWED_ROLES }
  validates :email, format: { with: /\A[^<].*[^>]\z/ }, uniqueness: true

  normalize_attributes :email, :display_name, :full_name

  class << self
    def user_roles_map
      ALLOWED_ROLES.map { |n| [I18n.t("user_roles.#{n}"), n] }
    end

    def find_or_invite(email_address, name = nil)
      existing = find_by_email(email_address)
      return existing if existing
      name = email_address.split('@').first if name.nil?
      User.invite!(full_name: name, email: email_address, approved: true)
    end

    def init_user_prefs
      joins('LEFT OUTER JOIN user_prefs ON user_prefs.user_id = users.id').
        where('user_prefs.id IS NULL').
        each { |u| u.create_user_prefs }
    end

    def email_digests!
      includes(:prefs, :subscribed_threads).where(user_prefs: {email_status_id: 2}).references(:user_prefs).each do |user|
        threads_messages = {}
        user.subscribed_threads.each do |thread|
          new_messages = thread.messages.where("updated_at > ?", 24.hours.ago)
          threads_messages[thread] = new_messages if new_messages.present?
        end
        ThreadMailer.digest(user, threads_messages).deliver_now if threads_messages.present?
      end
    end
  end

  def admin?
    role == 'admin'
  end

  def in_group_committee
    groups.includes(:memberships).where(group_memberships: {role: 'committee'}).references(:memberships)
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
    locations.map(&:buffered).join(&:union)
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

    # First, the first location.
    l = locations.order(id: :asc).first
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

  def can_view(other_users)
    users = User.arel_table
    profiles = UserProfile.arel_table
    memberships = GroupMembership.arel_table
    my_group_ids = groups.ids
    other_users.includes(:profile, :memberships).
      where(profiles[:visibility].eq('public').
            or(memberships[:group_id].in(my_group_ids)).
            or(users[:id].eq(id))).references(:user_profiles, :group_memberships)
  end

  # devise confirm! method overriden
  def confirm!
    welcome_message
    super
  end

  protected

  def add_memberships
    GroupMembership.transaction do
      potential_memberships = PotentialMember.includes(:group).email_eq(email)
      potential_memberships.find_each do |potential_member|
        membership = potential_member.group.memberships.create(user: self, role: "member")
        Notifications.group_membership_request_confirmed(membership).deliver_later
      end
      approve! if potential_memberships.exists?
    end
  end

  def set_default_role
    self.role = 'member'
  end

  # Devise hook for password validation
  def password_required?
    !invitation_token.present? && super
  end

  def welcome_message
    Notifications.new_user_confirmed(self).deliver_later
  end

  def set_public_token
    self.public_token = SecureRandom.hex(10)
  end
end
