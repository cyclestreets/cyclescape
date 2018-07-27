# frozen_string_literal: true

# == Schema Information
#
# Table name: groups
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  short_name             :string(255)      not null
#  website                :string(255)
#  email                  :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  disabled_at            :datetime
#  default_thread_privacy :string(255)      default("public"), not null
#
# Indexes
#
#  index_groups_on_short_name  (short_name)
#

class Group < ActiveRecord::Base
  has_many :memberships, class_name: 'GroupMembership', dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :membership_requests, class_name: 'GroupMembershipRequest', dependent: :destroy
  has_many :messages, -> { unscope(:order) }, through: :threads
  has_many :threads, class_name: 'MessageThread', inverse_of: :group
  has_many :potential_members
  has_many :hashtags

  has_one :profile, class_name: 'GroupProfile', dependent: :destroy, inverse_of: :group
  has_one :prefs, class_name: 'GroupPref', dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true, subdomain: true
  validates :default_thread_privacy, inclusion: { in: MessageThread::ALLOWED_PRIVACY }

  after_create :create_default_profile, unless: :profile
  after_create :create_default_prefs, unless: :prefs
  before_destroy :unlink_threads

  scope :ordered, -> { order('message_threads_count DESC NULLS LAST') }
  scope :enabled, -> { where(disabled_at: nil) }

  normalize_attributes :short_name, with: [:strip, :blank, :downcase]

  def self.from_geo_or_name(geo_name)
    geo_ids = from_geo(geo_name).ids
    name_ids = where(arel_table[:name].matches("%#{geo_name}%")).ids
    where(id: name_ids + geo_ids)
  end

  def self.from_geo(geo_name)
    return none if geo_name.blank?
    connection = Excon.new(SiteConfig.first.geocoder_url || Geocoder::GEO_URL, headers: { 'Accept' => Mime::JSON.to_s })
    rsp = connection.get(query: { q: geo_name, key: SiteConfig.first.geocoder_key || Geocoder::API_KEY})
    json = JSON.parse(rsp.body)
    bboxes = json["features"].map { |fe| BboxCoerce.call(fe["properties"]["bbox"]) }
    joins(:profile).
      merge(GroupProfile.local.intersects(bboxes.map(&:to_geometry).inject(&:union)))
  rescue JSON::ParserError
    none
  end

  def active_user_counts(since: 1.year.ago, limit: 15)
    subquery = members.select(:id).to_sql
    user_count = messages.approved.group(:created_by_id)
      .where("messages.created_at > ?", since)
      .where("messages.created_by_id IN (#{subquery})")
      .order("m_cnt DESC")
      .limit(limit)
      .pluck("messages.created_by_id, COUNT(*) AS m_cnt")
    users = User.where(id: user_count.map(&:first)).index_by(&:id)
    user_count.map do |(user_id, count)|
      {user: users[user_id], count: count }
    end
  end

  def committee_members
    members.includes(:memberships).where(group_memberships: {role: 'committee'}).
      order("LOWER(COALESCE(NULLIF(users.display_name, ''), NULLIF(users.full_name, '')))").references(:group_memberships)
  end

  def normal_members
    members.includes(:memberships).where(group_memberships: {role: 'member'})
      .order("LOWER(COALESCE(NULLIF(users.display_name, ''), NULLIF(users.full_name, '')))").references(:group_memberships)
  end

  def has_member?(user)
    members.include?(user)
  end

  def recent_issues
    Issue.intersects(profile.location).order('created_at DESC')
  end

  def to_param
    "#{id}-#{short_name}"
  end

  def name_with_email
    "#{name} <#{email}>"
  end

  def membership_for(user)
    memberships.where(user_id: user.id).first
  end

  def pending_membership_requests
    membership_requests.where(status: :pending)
  end

  def subdomain
    short_name
  end

  def start_location
    profile && profile.location
  end

  def thread_privacy_options_for(user)
    if committee_members.include?(user)
      MessageThread::ALLOWED_PRIVACY.dup
    else
      MessageThread::NON_COMMITTEE_ALLOWED_PRIVACY.dup
    end
  end

  def thread_privacy_options_map_for(user)
    thread_privacy_options_for(user).map { |n| [I18n.t("thread_privacy_options.#{n}"), n] }
  end

  def disable!
    update!(disabled_at: Time.current) unless disabled_at
  end

  def enable!
    update!(disabled_at: nil) if disabled_at
  end

  def update_potetial_members(emails)
    potential_members.destroy_all
    emails.split(/\r?\n/).each do |email|
      potential_members.build email: email
    end
    save
  end

  protected

  def create_default_profile
    profile = build_profile
    profile.new_user_email = I18n.t(
      "group_profiles.default_new_user_email",
      group_name: name,
      group_url: Rails.application.routes.url_helpers.root_url(
        subdomain: short_name, host: Rails.application.config.action_mailer.default_url_options[:host]
      )
    )
    profile.save!
  end

  def create_default_prefs
    build_prefs.save!
  end

  def unlink_threads
    threads.update_all(group_id: nil)
  end
end
