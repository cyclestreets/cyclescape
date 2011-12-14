# == Schema Information
#
# Table name: message_threads
#
#  id            :integer         not null, primary key
#  issue_id      :integer
#  created_by_id :integer         not null
#  group_id      :integer
#  title         :string(255)     not null
#  privacy       :string(255)     not null
#  state         :string(255)     not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class MessageThread < ActiveRecord::Base
  include FakeDestroy
  include Taggable

  ALLOWED_PRIVACY = %w(public group)

  belongs_to :created_by, class_name: "User"
  belongs_to :group
  belongs_to :issue
  has_many :messages, foreign_key: "thread_id", autosave: true, order: 'created_at ASC'
  has_many :subscriptions, class_name: "ThreadSubscription", foreign_key: "thread_id", conditions: {deleted_at: nil}
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :participants, through: :messages, source: :created_by, uniq: true
  has_many :user_priorities, class_name: "UserThreadPriority", foreign_key: "thread_id"
  has_and_belongs_to_many :tags, join_table: "message_thread_tags", foreign_key: "thread_id"

  scope :public, where("privacy = 'public'")
  scope :private, where("privacy = 'group'")
  default_scope where(deleted_at: nil)

  before_validation :set_public_token, on: :create

  validates :title, :state, :created_by_id, presence: true
  validates :privacy, inclusion: {in: ALLOWED_PRIVACY}

  state_machine :state, initial: :new do
  end

  def self.with_messages_from(user)
    where "EXISTS (SELECT id FROM messages m WHERE thread_id = message_threads.id AND m.created_by_id = ?)", user
  end

  def private_to_group?
    group_id && privacy == "group"
  end

  def public?
    privacy == "public"
  end

  def set_public_token
    self.public_token = generate_public_token
  end

  def message_count
    messages.count
  end

  def priority_for(user)
    user_priorities.where(user_id: user.id).first
  end

  protected

  def generate_public_token
    SecureRandom.hex(10)
  end
end
