class GroupMembershipRequest < ActiveRecord::Base
  attr_protected :state_event

  belongs_to :group
  belongs_to :user
  belongs_to :actioned_by, class_name: "User"

  validates :user, presence: true
  validates :group, presence: true

  state_machine :status, :initial => :pending do
    state :pending, :cancelled

    state :confirmed, :rejected do
      validates :actioned_by, presence: true
    end

    event :confirm do
      transition :pending => :confirmed
    end

    event :reject do
      transition :pending => :rejected
    end

    event :cancel do
      transition :pending => :cancelled
    end
  end

  def initalize
    super
  end
end
