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

class Group < ActiveRecord::Base
  attr_accessible :name, :short_name, :website, :email, :default_thread_privacy

  has_many :memberships, class_name: 'GroupMembership'
  has_many :members, through: :memberships, source: :user
  has_many :membership_requests, class_name: 'GroupMembershipRequest'
  has_many :threads, class_name: 'MessageThread'
  has_one :profile, class_name: 'GroupProfile'
  has_one :prefs, class_name: 'GroupPref'

  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true, subdomain: true
  validates :default_thread_privacy, inclusion: { in: MessageThread::ALLOWED_PRIVACY }

  after_create :create_default_profile, unless: :profile
  after_create :create_default_prefs, unless: :prefs

  def committee_members
    members.where("group_memberships.role = 'committee'").order("LOWER(COALESCE(NULLIF(users.display_name, ''), NULLIF(users.full_name, '')))")
  end

  def normal_members
    members.where("group_memberships.role = 'member'").order("LOWER(COALESCE(NULLIF(users.display_name, ''), NULLIF(users.full_name, '')))")
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
      MessageThread::ALLOWED_PRIVACY
    else
      MessageThread::ALLOWED_PRIVACY - ['committee']
    end
  end

  def thread_privacy_options_map_for(user)
    thread_privacy_options_for(user).map { |n| [I18n.t(".thread_privacy_options.#{n.to_s}"), n] }
  end

  protected

  def create_default_profile
    build_profile.save!
  end

  def create_default_prefs
    build_prefs.save!
  end
end
