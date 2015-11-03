# == Schema Information
#
# Table name: messages
#
#  id             :integer          not null, primary key
#  created_by_id  :integer          not null
#  thread_id      :integer          not null
#  body           :text             not null
#  component_id   :integer
#  component_type :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#  censored_at    :datetime
#
# Indexes
#
#  index_messages_on_created_by_id  (created_by_id)
#  index_messages_on_thread_id      (thread_id)
#

class Message < ActiveRecord::Base
  include FakeDestroy
  include AASM
  include Rakismet::Model

  belongs_to :thread, class_name: 'MessageThread'
  belongs_to :created_by, class_name: 'User'
  belongs_to :component, polymorphic: true, autosave: true
  belongs_to :in_reply_to, class_name: 'Message'

  before_validation :init_blank_body, on: :create, if: :component
  before_validation :set_public_token, on: :create

  before_save :set_in_reply_to
  after_save  :update_thread_search

  scope :recent,     -> { order('created_at DESC').limit(3) }
  scope :approved,   -> { where(status: [nil, 'approved']) }
  scope :mod_queued, -> { where(status: 'mod_queued') }
  scope :in_group,   ->(group_id) { includes(:thread).where(message_threads: {group_id: group_id}).references(:thread)}
  validates :created_by, presence: true
  validates :body, presence: true, unless: :component
  validate  :in_reply_to_should_belong_to_same_thread

  rakismet_attrs  author: proc { created_by.full_name },
    author_email: proc { created_by.email },
    content: proc { body }

  aasm column: 'status' do
    state :mod_queued, initial: true
    state :approved
    state :rejected

    event :mod_queue do
      transitions to: :mod_queued, guard: :check_reason
    end

    event :reject do
      transitions from: :mod_queued, to: :rejected
    end

    event :skip_mod_queue do
      transitions from: :mod_queued, to: :approved, after: [:approve_related]
    end

    event :approve do
      transitions to: :approved, after: [:ham!, :approve_related]
    end
  end

  def censor!
    self.censored_at = Time.now
    save!
  end

  def censored?
    censored_at
  end

  def component_name
    (component ? component : self).class.name.underscore
  end

  def searchable_text
    component ? "#{body} #{component.searchable_text}" : body
  end

  def update_thread_search
    SearchUpdater.update_thread(thread) if thread
    true
  end

  protected

  def init_blank_body
    self.body ||= ''
  end

  def set_in_reply_to
    self.in_reply_to ||= thread.messages.last
  end

  def set_public_token
    self.public_token = SecureRandom.hex(10)
  end

  def in_reply_to_should_belong_to_same_thread
    return unless in_reply_to
    errors.add :in_reply_to_id, :invalid unless in_reply_to.thread.id == thread.id
  end

  def approve_related
    created_by.approve! unless created_by.approved?
    if thread.approved?
      ThreadNotifier.notify_subscribers thread, :new_message, self
    else
      thread.approve!
    end
  end
end
