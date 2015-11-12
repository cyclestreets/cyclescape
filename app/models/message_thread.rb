# == Schema Information
#
# Table name: message_threads
#
#  id            :integer          not null, primary key
#  issue_id      :integer
#  created_by_id :integer          not null
#  group_id      :integer
#  title         :string(255)      not null
#  privacy       :string(255)      not null
#  state         :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  public_token  :string(255)
#
# Indexes
#
#  index_message_threads_on_created_by_id  (created_by_id)
#  index_message_threads_on_group_id       (group_id)
#  index_message_threads_on_issue_id       (issue_id)
#  index_message_threads_on_public_token   (public_token) UNIQUE
#

class MessageThread < ActiveRecord::Base
  include AASM
  include FakeDestroy
  include Taggable

  searchable do
    text :title, :messages_text, :tags_string
    integer :group_id
    string :privacy
    string :status
    time :latest_activity_at, stored: true, trie: true
    latlon(:location) do
      if issue
        centre = issue.centre
        Sunspot::Util::Coordinates.new(centre.y, centre.x)
      end
    end
  end

  ALLOWED_PRIVACY = %w(public group committee)

  belongs_to :created_by, class_name: 'User'
  belongs_to :group, inverse_of: :threads
  belongs_to :issue
  has_many :messages, -> { order('created_at ASC') }, foreign_key: 'thread_id', autosave: true, inverse_of: :thread
  has_many :subscriptions, -> { where(deleted_at: nil) }, class_name: 'ThreadSubscription', foreign_key: 'thread_id', inverse_of: :thread
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :participants, -> { (uniq(true)) }, through: :messages, source: :created_by
  has_many :user_priorities, class_name: 'UserThreadPriority', foreign_key: 'thread_id', inverse_of: :thread
  has_many :message_thread_closes
  has_many :closed_by, through: :message_thread_closes, source: :user
  has_and_belongs_to_many :tags, join_table: 'message_thread_tags', foreign_key: 'thread_id'
  has_one :latest_message, -> { order('created_at DESC') }, foreign_key: 'thread_id',  class_name: 'Message'

  scope :is_public,     -> { where(privacy: 'public') }
  scope :with_issue,    -> { where.not(issue_id: nil) }
  scope :without_issue, -> { where(issue_id: nil) }
  scope :approved,      -> { where(status: 'approved') }
  scope :mod_queued,    -> { where(status: 'mod_queued') }

  default_scope { where(deleted_at: nil) }

  before_validation :set_public_token, on: :create

  validates :title, :created_by, presence: true
  validates :privacy, inclusion: { in: ALLOWED_PRIVACY }
  validate :must_be_created_by_enabled_user, on: :create

  aasm column: 'status' do
    state :mod_queued, initial: true
    state :approved, before_enter: :approve_related

    event :approve do
      transitions to: :approved
    end
  end

  class << self
    def non_committee_privacies_map
      (ALLOWED_PRIVACY - ['committee']).map { |n| [I18n.t("thread_privacy_options.#{n.to_s}"), n] }
    end

    def privacies_map
      ALLOWED_PRIVACY.map { |n| [I18n.t("thread_privacy_options.#{n.to_s}"), n] }
    end

    def with_messages_from(user)
      where 'EXISTS (SELECT id FROM messages m WHERE thread_id = message_threads.id AND m.created_by_id = ?)', user
    end

    def order_by_latest_message
      rel = joins("JOIN (SELECT thread_id, MAX(created_at) AS created_at FROM messages m GROUP BY thread_id)" \
                  "AS latest ON latest.thread_id = message_threads.id")
      rel.order('latest.created_at DESC')
    end

    def with_upcoming_deadlines
      rel = joins("JOIN (SELECT m.thread_id, MIN(deadline) AS deadline
                  FROM messages m
                  JOIN deadline_messages dm ON m.component_id = dm.id
                  WHERE m.component_type = 'DeadlineMessage'
                    AND dm.deadline >= current_date
                    AND m.censored_at IS NULL
                  GROUP BY m.thread_id)
                AS m2
                ON m2.thread_id = message_threads.id")
      rel.order('m2.deadline ASC')
    end
  end

  def display_title
    if closed
      "(Closed) #{title}"
    else
      title
    end
  end

  def close_by! user
    if update(closed: true)
      message_thread_closes.create(user: user, event: 'closed')
    end
  end

  def open_by! user
    if update(closed: false)
      message_thread_closes.create(user: user, event: 'opened')
    end
  end

  def add_subscriber(user)
    found = user.thread_subscriptions.to(self)
    if found
      # Reset the subscription
      found.undelete!
      found
    else
      subscriptions.create( user: user )
    end
  end

  def add_messages_from_email!(mail, in_reply_to)
    from_address = mail.message.header[:from].addresses.first
    from_name = mail.message.header[:from].display_names.first

    user = User.find_or_invite(from_address, from_name)
    fail "Invalid user: #{from_address.inspect} #{from_name.inspect}" if user.nil?

    # For multipart messages we pull out the text/plain content
    text =  if mail.message.multipart?
              mail.message.text_part.decoded
            else
              mail.message.decoded
            end

    parsed = EmailReplyParser.read(text)
    stripped = parsed.fragments.select { |f| !f.hidden? }.join("\n")

    if closed
      self.actioned_by = user
      open!
    end
    messages.create!(body: stripped, created_by: user, in_reply_to: in_reply_to).tap { |mes| mes.skip_mod_queue! }

    # Attachments
    mail.message.attachments.each do |attachment|
      next if attachment.content_type.include?('pgp-signature') || attachment.content_type.include?('pkcs7')

      component = if attachment.content_type.start_with?('image/')
                    PhotoMessage.new(photo: attachment.body.decoded, caption: attachment.filename)
                  else
                    DocumentMessage.new(file: attachment.body.decoded, title: attachment.filename)
                  end
      message              = messages.build(created_by: user, in_reply_to: in_reply_to)
      component.thread     = self
      component.message    = message
      component.created_by = user
      message.component    = component
      message.save!
      message.skip_mod_queue!
    end
  end

  def email_subscribers
    subscribers.joins(:prefs).where(user_prefs: { enable_email: true })
  end

  def private_to_committee?
    group_id && privacy == 'committee'
  end

  def private_to_group?
    group_id && privacy == 'group'
  end

  def public?
    privacy == 'public'
  end

  def has_issue?
    issue_id
  end

  def set_public_token
    self.public_token = generate_public_token
  end

  def message_count
    messages.count
  end

  def first_message
    messages.order('id').first
  end

  def latest_activity_at
    messages.empty? ? updated_at : messages.last.updated_at
  end

  def latest_activity_at_to_i
    latest_activity_at.to_i
  end

  def latest_activity_by
    messages.empty? ? created_by : messages.last.created_by
  end

  def default_centre
    # returns location of (in order of preference)
    # 1. issue (even if it is deleted)
    # 2. group profile location (if the group has a profile and the profile has a location)
    # 3. the creators location (if they have one)
    # 4. nowhere in particular
    locatable = Issue.unscoped.find issue_id if issue_id
    locatable = locatable || (group.try :profile if group.try(:profile).try(:location)) || created_by.locations.first
    locatable ? locatable.centre : Geo::NOWHERE_IN_PARTICULAR
  end

  def upcoming_deadline_messages
    messages.includes(:component).except(:order).joins('JOIN deadline_messages dm ON messages.component_id = dm.id').
      where("messages.component_type = 'DeadlineMessage'").
      where('dm.deadline >= current_date').
      where('messages.censored_at IS NULL').
      order('dm.deadline ASC')
  end

  def priority_for(user)
    user_priorities.find_by(user_id: user.id)
  end

  def messages_text
    messages.approved.map(&:searchable_text).join(' ')
  end

  # for auth checks
  def group_committee_members
    if group_id
      group.committee_members
    else
      []
    end
  end

  protected

  def generate_public_token
    SecureRandom.hex(10)
  end

  def must_be_created_by_enabled_user
    return unless created_by
    errors.add :base, :disabled if created_by.disabled
  end

  def approve_related
    unless approved?
      ThreadSubscriber.subscribe_users self
      ThreadNotifier.notify_subscribers self, :new_message, first_message

      NewThreadNotifier.notify_new_thread self
      SearchUpdater.update_thread(self)
    end
    true
  end

end
