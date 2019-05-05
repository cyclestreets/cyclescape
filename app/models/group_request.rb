# frozen_string_literal: true

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

class GroupRequest < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :actioned_by, class_name: 'User'

  validates :user, :name, :short_name, :email, presence: true
  validates :name, :short_name, :email, uniqueness: true
  validate :name_is_not_taken, :short_name_is_not_taken, :email_is_not_taken, unless: :confirmed?
  validates :short_name, subdomain: true
  validates :default_thread_privacy, inclusion: { in: MessageThread::ALLOWED_PRIVACY }

  normalize_attributes :short_name, with: [:strip, :blank, :downcase]
  normalize_attributes :email

  aasm column: 'status' do
    state :pending, initial: true
    state :cancelled

    state :confirmed, before_enter: :create_group
    state :rejected

    event :confirm do
      transitions from: :pending, to: :confirmed, guard: :actioned_by
    end

    event :reject do
      transitions from: :pending, to: :rejected, guard: :actioned_by
    end

    event :cancel do
      transitions from: :pending, to: :cancelled
    end

    # to only be done manually
    event :unconfirm do
      transitions from: :confirmed, to: :pending, guard: :actioned_by, after: [:destroy_group]
    end
  end

  def create_group
    user.approve!
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

  def destroy_group
    Group.find_by(short_name: short_name).destroy
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
