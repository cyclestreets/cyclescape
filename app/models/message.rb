# frozen_string_literal: true

class Message < ApplicationRecord
  include FakeDestroy
  include AASM
  include Rakismet::Model
  include BodyFormat
  include MessageComponents

  self.ignored_columns = %w[component_id component_type]

  belongs_to :thread, -> { with_deleted }, class_name: "MessageThread", inverse_of: :messages
  belongs_to :created_by, -> { with_deleted }, class_name: "User", inverse_of: :messages
  belongs_to :in_reply_to, class_name: "Message"
  belongs_to :inbound_mail
  has_many :hashtaggings, dependent: :destroy
  has_many :hashtags, through: :hashtaggings
  has_many(
    :completing_action_messages,
    class_name: "ActionMessage", dependent: :destroy,
    inverse_of: :completing_message, foreign_key: :completing_message_id
  )

  COMPONENT_TYPES = %i[
    photo_messages
    cyclestreets_photo_messages
    street_view_messages
    map_messages
    link_messages
    deadline_messages
    document_messages
    action_messages
    thread_leader_messages
    library_item_messages
  ].freeze

  COMPONENT_TYPES.each do |component_type|
    has_many component_type, dependent: :destroy, inverse_of: :message
    if component_type != :deadline_messages # rubocop:disable Style/IfUnlessModifier
      accepts_nested_attributes_for component_type, reject_if: :all_blank
    end
  end
  accepts_nested_attributes_for :deadline_messages, reject_if: proc { |attr| attr["deadline"].blank? }

  before_validation :set_public_token, on: :create

  before_create :set_in_reply_to
  before_save :attach_tags
  after_commit :update_search
  acts_as_voteable

  scope :recent, -> { ordered.limit(3) }
  scope :ordered, -> { order(created_at: :desc) }
  scope :ordered_for_thread_view, -> { order(created_at: :asc) }
  scope :approved,   -> { where(status: [nil, "approved"]) }
  scope :mod_queued, -> { where(status: "mod_queued") }
  scope :in_group,   ->(group_id) { includes(:thread).where(message_threads: { group_id: group_id }).references(:thread) }
  scope :after_date, ->(date) { where(arel_table[:created_at].gteq(date)) }
  scope :before_date, ->(date) { where(arel_table[:created_at].lteq(date)) }

  validates :created_by, presence: true
  validates :body, presence: true, unless: :components?
  validate  :in_reply_to_should_belong_to_same_thread

  rakismet_attrs  author: proc { created_by.full_name },
                  author_email: proc { created_by.email },
                  content: proc { body }

  normalize_attribute :body, with: %i[strip_fb_links strip_html_paragraphs]

  aasm column: "status" do
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
      transitions to: :approved, after: %i[ham! approve_related]
    end
  end

  def censor!
    self.censored_at = Time.current
    save!
  end

  def components_and_self
    arr = components
    arr.unshift(self) if body
    arr
  end

  def components
    COMPONENT_TYPES.flat_map { |component| public_send(component) }
  end

  def components?
    components.present?
  end

  def censored?
    censored_at
  end

  def searchable_text
    components? ? "#{body} #{components.map(&:searchable_text).join(' ')}" : body
  end

  def committee_created?
    created_by.id.in?(thread.try(:group).try(:committee_members).try(:ids) || [])
  end

  def as_json(_options = nil)
    {
      id: id,
      thread_id: thread_id,
      body: body,
      created_at: created_at,
      updated_at: updated_at,
      public_token: public_token,
      in_reply_to_id: in_reply_to_id
    }
  end

  protected

  def update_search
    SearchUpdater.update_type(thread, :process_thread) if thread
    true
  end

  def set_in_reply_to
    self.in_reply_to ||= thread.messages.where.not(id: nil).last
  end

  def attach_tags
    return unless thread.group

    self.hashtags = Hashtag.find_or_create_for_body(body, thread.group)
  end

  def set_public_token
    self.public_token = SecureRandom.hex(10)
  end

  def in_reply_to_should_belong_to_same_thread
    return unless in_reply_to

    errors.add :in_reply_to_id, :invalid unless in_reply_to.thread_id == thread_id
  end

  def approve_related
    thread.add_subscriber(created_by) unless created_by.subscribed_to_thread?(thread)
    created_by.approve! unless created_by.approved?
    if thread.approved?
      ThreadNotifier.notify_subscribers thread, self
    else
      thread.approve!
    end
    true
  end
end

# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  body            :text             not null
#  censored_at     :datetime
#  check_reason    :string
#  component_type  :string(255)
#  deleted_at      :datetime
#  public_token    :string           not null
#  status          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  component_id    :integer
#  created_by_id   :integer          not null
#  in_reply_to_id  :integer
#  inbound_mail_id :integer
#  thread_id       :integer          not null
#
# Indexes
#
#  index_messages_on_component_id_and_component_type  (component_id,component_type)
#  index_messages_on_created_by_id                    (created_by_id)
#  index_messages_on_in_reply_to_id                   (in_reply_to_id)
#  index_messages_on_public_token                     (public_token) UNIQUE
#  index_messages_on_thread_id                        (thread_id)
#
# Foreign Keys
#
#  fk_rails_...  (inbound_mail_id => inbound_mails.id)
#
