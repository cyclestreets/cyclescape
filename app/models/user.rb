# frozen_string_literal: true

class User < ApplicationRecord
  ALLOWED_ROLES = %w[member admin].freeze
  SEARCHABLE_COLUMNS = %w[full_name display_name email].freeze

  include Searchable

  acts_as_voter
  acts_as_paranoid

  devise(:database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :validatable, :invitable,
         :omniauthable, omniauth_providers: %i[facebook twitter])

  has_many :memberships, class_name: "GroupMembership", dependent: :destroy
  has_many :groups, through: :memberships
  has_many :membership_requests, class_name: "GroupMembershipRequest", dependent: :destroy
  has_many :requested_groups, through: :membership_requests, source: :group
  has_many :actioned_membership_requests, foreign_key: "actioned_by_id", class_name: "GroupMembershipRequest"
  has_many :issues, foreign_key: "created_by_id"
  has_many :created_threads, class_name: "MessageThread", foreign_key: "created_by_id"
  has_many :messages, foreign_key: "created_by_id"
  has_many :thread_subscriptions, dependent: :destroy do
    def to(thread)
      where(thread: thread).order(deleted_at: :desc).first
    end
  end
  # Would be better using the 'active' named scope on thread_subscriptions instead of the conditions block. But how?
  has_many :subscribed_threads, -> { where("thread_subscriptions.deleted_at is NULL").merge(MessageThread.approved) },
           through: :thread_subscriptions, source: :thread
  has_many :thread_favourites, class_name: "UserThreadFavourite", inverse_of: :user
  has_many :favourite_threads, through: :thread_favourites, source: :thread
  has_many :thread_views, inverse_of: :user
  has_many :site_comments
  has_many :private_threads, class_name: "MessageThread", inverse_of: :user
  has_many :thread_leader_messages, -> { active }, dependent: :destroy, inverse_of: :created_by, foreign_key: :created_by_id
  has_many :leading_threads, through: :thread_leader_messages, source: :thread, inverse_of: :leaders
  has_many :user_blocks
  has_many :blocked_users, through: :user_blocks, source: :blocked
  has_many :user_blocked_by, class_name: "UserBlock", foreign_key: :blocked_id
  has_many :blocked_by_users, through: :user_blocked_by, source: :user
  has_many :poll_votes, dependent: :destroy
  has_many :poll_options, through: :poll_votes
  has_one :profile, class_name: "UserProfile"
  has_one :prefs, class_name: "UserPref"
  has_one :location, class_name: "UserLocation", dependent: :destroy
  belongs_to :remembered_group, class_name: "Group"

  accepts_nested_attributes_for :profile, update_only: true

  before_validation :set_default_role, unless: :role
  after_create :create_user_prefs
  after_create :add_memberships
  before_create :set_public_token

  before_destroy :obfuscate_name
  before_destroy :clear_profile

  scope :active, -> { where('"users".disabled_at IS NULL AND "users".confirmed_at IS NOT NULL AND "users".deleted_at IS NULL') }
  scope :admin,  -> { where(role: "admin") }
  scope :is_public, -> { joins(:profile).where(user_profiles: { visibility: "public" }) }
  scope :ordered, lambda { |group_id|
    joins("LEFT OUTER JOIN group_memberships gms ON (users.id = gms.user_id AND gms.group_id = #{group_id || -1})")
      .order("gms.role", Arel.sql("SUBSTRING(full_name, '([^[:space:]]+)$')"))
  }

  validates :full_name, presence: true, format: { without: /[\[\]]/ }
  validates :display_name, uniqueness: true, allow_nil: true
  validates :role, presence: true, inclusion: { in: ALLOWED_ROLES }
  validates :email, format: { with: /\A[^<].*[^>]\z/ }, uniqueness: true

  normalize_attributes :email, :display_name, :full_name

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.full_name = auth.info.name
      user.display_name = auth.info.nickname
      user.build_profile(picture_url: auth.info.image)
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      user.skip_confirmation!
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if (info = session["devise.omniauth_data_info"])
        user.email = info.email if user.email.blank?
        user.full_name = info.name
        user.display_name = info.nickname
      end
    end
  end

  class << self
    def user_roles_map
      ALLOWED_ROLES.map { |n| [I18n.t("user_roles.#{n}"), n] }
    end

    def find_or_invite(email_address, name = nil)
      existing = find_by(email: email_address)
      return existing if existing

      name = email_address.split("@").first if name.nil?
      User.invite!(full_name: name, email: email_address, approved: true)
    end

    def init_user_prefs
      joins("LEFT OUTER JOIN user_prefs ON user_prefs.user_id = users.id")
        .where("user_prefs.id IS NULL")
        .find_each(&:create_user_prefs)
    end

    def email_digests!
      includes(:prefs, :subscribed_threads).where(user_prefs: { email_status_id: 2 }).references(:user_prefs).find_each do |user|
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
    role == "admin"
  end

  def groups_can_assign
    if admin?
      Group.all
    else
      groups
    end
  end

  def in_group_committee
    groups.includes(:memberships).where(group_memberships: { role: "committee" }).references(:memberships)
  end

  def approve!
    update approved: true
  end

  def name
    return display_name if display_name.present?

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
  alias profile_without_auto_build profile
  alias profile profile_with_auto_build

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def subscribed_to_thread?(thread, all_subscriptions: nil)
    if all_subscriptions
      all_subscriptions.to_a.find { |sub| sub.thread == thread }
    else
      thread_subscriptions.active.to(thread)
    end
  end

  def ever_subscribed_to_thread?(thread)
    thread_subscriptions.to(thread)
  end

  def involved_threads
    MessageThread.with_messages_from(self)
  end

  def viewed_thread_at(thread)
    thread_views.find_by(thread: thread)&.viewed_at
  end

  def disabled
    disabled_at?
  end

  def disabled=(d)
    self.disabled_at = Time.zone.now if d == "1" && !disabled_at?
    self.disabled_at = nil if d == "0" && disabled_at?
  end

  def buffered_location
    location&.buffered unless location&.destroyed?
  end

  # Returns issues that are within a small distance of their user_locations
  def issues_near_locations
    issue_ids = Rails.cache.fetch("issues_near:#{id}", expires_in: 10.minutes) do
      Issue.intersects(buffered_location).ids
    end
    Issue.where(id: issue_ids)
  end

  def planning_applications_near_locations
    time = Time.current
    # Expire the planning_applications ids at 4am tomorrow
    planning_ids = Rails.cache.fetch("planning_near:#{id}", expires_in: (time.tomorrow.change(hour: 4) - time)) do
      PlanningApplication.intersects(buffered_location).not_hidden.relevant.ids
    end
    PlanningApplication.where(id: planning_ids)
  end

  def start_location
    # Figure out a suitable starting location for the user, e.g. for adding new issues.

    # First, there location.
    return location.location if location

    # Figure out the group from the subdomain, and use that if possible
    # group = <enter some code here>
    # return group.profile.location if group.profile.location

    # Take the location from the first of their groups that has a location
    groups.each do |g|
      return g.profile.location if g.profile.location
    end

    # Give up
    SiteConfig.first.nowhere_location
  end

  def create_user_prefs
    build_prefs.save!
  end

  def membership_request_pending_for?(group)
    membership_requests.where(group_id: group.id, status: :pending).exists?
  end

  def non_committee_member_of?(group)
    memberships.normal.where(group: group).exists?
  end

  def update_remembered_group(group)
    # Not using association to avoid validation checks
    new_id = group.try(:id)
    update_column(:remembered_group_id, new_id) unless remembered_group_id == new_id
  end

  def remembered_group?
    remembered_group
  end

  def obfuscate_name
    self.full_name = "User #{id} (deleted)"
    self.display_name = nil
    self.email = "deleted-user-#{id}-#{SecureRandom.uuid}@cyclescape.org"
    self.uid = "deleted-#{uid}"
    true
  end

  def display_name_or_anon
    display_name || I18n.t("anon")
  end

  def api_key
    self["api_key"] || generate_new_api_key
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
    other_users.includes(:profile, :memberships)
               .where(profiles[:visibility].eq("public")
            .or(memberships[:group_id].in(my_group_ids))
            .or(users[:id].eq(id))).references(:user_profiles, :group_memberships)
  end

  # devise confirm method overriden
  def confirm
    welcome_message
    super
  end

  private

  def generate_new_api_key
    tries = 5
    begin
      new_api_key = SecureRandom.urlsafe_base64
      update!(api_key: new_api_key)
      new_api_key
    rescue ActiveRecord::RecordNotUnique => e
      if e.message.match(/index_users_on_api_key/) && tries.positive?
        tries -= 1
        retry
      else
        raise e
      end
    end
  end

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
    self.role = "member"
  end

  # Devise hook for password validation
  def password_required?
    invitation_token.blank? && super
  end

  def welcome_message
    Notifications.new_user_confirmed(self).deliver_later
  end

  def set_public_token
    self.public_token = SecureRandom.hex(10)
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  api_key                :string
#  approved               :boolean          default(FALSE), not null
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  deleted_at             :datetime
#  disabled_at            :datetime
#  display_name           :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(128)      default("")
#  full_name              :string(255)      not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string(255)
#  invited_by_type        :string(255)
#  last_seen_at           :datetime
#  provider               :string
#  public_token           :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  role                   :string(255)      not null
#  uid                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#  remembered_group_id    :integer
#
# Indexes
#
#  index_users_on_api_key              (api_key) UNIQUE
#  index_users_on_display_name         (display_name) UNIQUE
#  index_users_on_email                (email) UNIQUE
#  index_users_on_invitation_token     (invitation_token)
#  index_users_on_provider_and_uid     (provider,uid) UNIQUE
#  index_users_on_public_token         (public_token) UNIQUE
#  index_users_on_remembered_group_id  (remembered_group_id)
#
