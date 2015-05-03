class GroupRequest < ActiveRecord::Base
  attr_protected :state_event

  belongs_to :user
  belongs_to :actioned_by, class_name: 'User'

  attr_accessible :email, :name, :short_name, :website, :default_thread_privacy, :message
  validates :user, :name, :short_name, :email, presence: true
  validates :name, :short_name, :email, uniqueness: true
  validate :name_is_not_taken, :short_name_is_not_taken, :email_is_not_taken
  validate :short_name, format: { with: /\A[a-z0-9]+\z/ }

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
    membership = group.memberships.new
    membership.user = user
    membership.role = 'committee'
    membership.save
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
