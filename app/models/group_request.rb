# == Schema Information
#
# Table name: group_requests
#
#  id                     :integer          not null, primary key
#  status                 :string(255)
#  user_id                :integer          not null
#  actioned_by_id         :integer
#  name                   :string(255)      not null
#  short_name             :string(255)      not null
#  default_thread_privacy :string(255)      default("public"), not null
#  website                :string(255)
#  email                  :string(255)      not null
#  message                :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  rejection_message      :text
#
# Indexes
#
#  index_group_requests_on_name        (name) UNIQUE
#  index_group_requests_on_short_name  (short_name) UNIQUE
#  index_group_requests_on_user_id     (user_id)
#

class GroupRequest < ActiveRecord::Base

  belongs_to :user
  belongs_to :actioned_by, class_name: 'User'

  validates :user, :name, :short_name, :email, presence: true
  validates :name, :short_name, :email, uniqueness: true
  validate :name_is_not_taken, :short_name_is_not_taken, :email_is_not_taken, unless: :confirmed?
  validates :short_name, subdomain: true
  validates :default_thread_privacy, inclusion: { in: MessageThread::ALLOWED_PRIVACY }

  state_machine :status, initial: :pending do
    after_transition any => :confirmed do |request, transition|
      transition.rollback unless request.create_group
    end

    state :pending, :cancelled

    state :confirmed, :rejected do
      validates :actioned_by, presence: true
    end

    event :confirm do
      transition pending: :confirmed
    end

    event :reject do
      transition pending: :rejected
    end

    event :cancel do
      transition pending: :cancelled
    end
  end

  def create_group
    group = Group.create attributes.slice('name', 'short_name', 'website', 'email', 'default_thread_privacy')
    if group.valid?
      membership = group.memberships.new
      membership.user = user
      membership.role = 'committee'
      membership.save
    else
      false
    end
  end

  private

  def name_is_not_taken
    errors.add(:name, :taken) if Group.where(name: name).present?
  end

  def short_name_is_not_taken
    errors.add(:short_name, :taken) if Group.where(short_name: short_name).present?
  end

  def email_is_not_taken
    errors.add(:email, :taken) if Group.where(email: email).present?
  end
end
