# frozen_string_literal: true

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

  searchable auto_index: false do
    text :title, :messages_text, :tags_string, :id
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

  ALL_ALLOWED_PRIVACY = %w(public group committee private).freeze
  ALLOWED_PRIVACY = ALL_ALLOWED_PRIVACY - %w(private)
  NON_COMMITTEE_ALLOWED_PRIVACY = ALL_ALLOWED_PRIVACY - %w(private committee)

  belongs_to :created_by, -> { with_deleted }, class_name: 'User'
  belongs_to :group, inverse_of: :threads, counter_cache: true
  belongs_to :issue, inverse_of: :threads
  belongs_to :user, inverse_of: :private_threads
  has_many :messages, -> { order(created_at: :asc) }, foreign_key: 'thread_id', autosave: true, inverse_of: :thread
  has_many :subscriptions, -> { where(deleted_at: nil) }, class_name: 'ThreadSubscription', foreign_key: 'thread_id', inverse_of: :thread
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :participants, -> { (uniq(true)) }, through: :messages, source: :created_by
  has_many :user_priorities, class_name: 'UserThreadPriority', foreign_key: 'thread_id', inverse_of: :thread
  has_many :message_thread_closes, dependent: :destroy
  has_many :closed_by, through: :message_thread_closes, source: :user
  has_many :map_messages, foreign_key: :thread_id, inverse_of: :thread
  has_many :action_messages, foreign_key: :thread_id, inverse_of: :thread
  has_many :deadline_messages, foreign_key: :thread_id, inverse_of: :thread
  has_many :thread_leader_messages, -> { active }, dependent: :destroy, foreign_key: :thread_id
  has_many :leaders, through: :thread_leader_messages, source: :created_by, inverse_of: :leading_threads
  has_many :thread_views, inverse_of: :thread, foreign_key: :thread_id, dependent: :destroy
  has_and_belongs_to_many :tags, join_table: 'message_thread_tags', foreign_key: :thread_id
  has_one :latest_message, -> { order('created_at DESC').approved }, foreign_key: :thread_id,  class_name: 'Message'

  scope :is_public,        -> { where(privacy: 'public') }
  scope :with_issue,       -> { where.not(issue_id: nil) }
  scope :without_issue,    -> { where(issue_id: nil) }
  scope :approved,         -> { where(status: 'approved') }
  scope :mod_queued,       -> { where(status: 'mod_queued') }
  scope :is_private,       -> { where(privacy: 'private') }
  scope :private_for, ->(usr) do
    is_private.where(arel_table[:created_by_id].eq(usr.id).or(arel_table[:user_id].eq(usr.id)))
  end
  scope :unviewed_for, ->(usr) do
    return none unless usr
    messages = Message.arel_table
    thread_views = ThreadView.arel_table
    approved.joins(:latest_message,
                   arel_table.join(thread_views, Arel::Nodes::OuterJoin)
      .on(thread_views[:thread_id].eq(arel_table[:id]), thread_views[:user_id].eq(usr.id)).join_sources)
      .merge(Message.approved)
      .where(messages[:created_at].gt(thread_views[:viewed_at]).or(thread_views[:viewed_at].eq(nil)))
  end
  scope :after_date, ->(date) { where(arel_table[:created_at].gteq(date)) }
  scope :before_date, ->(date) { where(arel_table[:created_at].lteq(date)) }
  scope :after_id, ->(id) { where(arel_table[:id].gt(id)) }

  default_scope { where(deleted_at: nil) }

  before_validation :set_public_token, on: :create
  after_create      :add_subscribers
  after_commit      :add_auto_subscribers
  after_commit      :approve_related

  validates :title, :created_by, presence: true
  validates :privacy, inclusion: { in: ALL_ALLOWED_PRIVACY }
  validates :group, presence: true, if: ->(thread) { thread.privacy == "group" }
  validate :must_be_created_by_enabled_user, on: :create

  aasm column: 'status', requires_lock: true do
    state :mod_queued, initial: true
    state :approved

    event :approve do
      transitions to: :approved
    end
  end

  class << self
    def non_committee_privacies_map
      NON_COMMITTEE_ALLOWED_PRIVACY.map do |n|
        [I18n.t("thread_privacy_options.#{n}"), n]
      end
    end

    def privacies_map
      ALLOWED_PRIVACY.map do |n|
        [I18n.t("thread_privacy_options.#{n}"), n]
      end
    end

    def with_messages_from(user)
      where 'EXISTS (SELECT id FROM messages m WHERE thread_id = message_threads.id AND m.created_by_id = ?)', user
    end

    def order_by_latest_message
      rel = joins("JOIN (SELECT thread_id, MAX(created_at) AS created_at FROM messages m WHERE m.status in (NULL, 'approved') GROUP BY thread_id )" \
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

    def unviewed_private_count(user)
      private_for(user).unviewed_for(user).count
    end

    # @param user [User]
    # @param threads [Array<MessageThread>] or [ActiveRecord::Relation<MessageThread>] of threads ask if the user has viewed
    # @return [Array<Integer>] ids of unviewed threads
    def unviewed_thread_ids(user:, threads:)
      ids = if threads.is_a?(ActiveRecord::Relation) && !threads.loaded?
              threads.ids
            else
              threads.map(&:id)
            end
      where(id: ids).unviewed_for(user).distinct.ids
    end
  end

  def display_title
    if closed
      "(#{self.class.human_attribute_name(:closed)}) #{title}"
    elsif mod_queued?
      "(#{self.class.human_attribute_name(:moderated)}) #{title}"
    else
      title
    end
  end

  def committee_members
    group.try(:committee_members) || User.none
  end

  def display_id
    "##{id}"
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
    return true if user.thread_subscriptions.to(self).try(:undelete!)
    begin
      subscriptions.find_or_create_by!(user: user, deleted_at: nil)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  def add_messages_from_email!(mail, in_reply_to)
    from_address = mail.message.header[:from].addresses.first
    from_name = mail.message.header[:from].display_names.first
    h = ActionController::Base.helpers

    user = User.find_or_invite(from_address, from_name)
    fail "Invalid user: #{from_address.inspect} #{from_name.inspect}" if user.nil?

    text = if mail.message.html_part
             # For multipart messages we pull out the html part content and use python to remove the signature
             body = %x(./lib/sig_strip.js #{Shellwords.escape(mail.message.html_part.decoded)})
             body.gsub(%r{(</?html>|</?body>|</?head>|\r)},"")
           else
             # When there is no HTML we get the text part or just the message and use EmailReplyParser to remove the signature
             body = (mail.message.text_part || mail.message).decoded
             parsed = EmailReplyParser.read(body)
             stripped = parsed.fragments.select { |f| !f.hidden? }.join("\n")
             h.simple_format(stripped)
           end
    text = h.auto_link(text)

    open_by!(user) if closed
    messages.create!(body: text, created_by: user, in_reply_to: in_reply_to).tap { |mes| mes.skip_mod_queue! }

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
    subscribers.joins(:prefs).where(user_prefs: { email_status_id: 1 })
  end

  def private_to_committee?
    group_id && privacy == 'committee'
  end

  def private_to_group?
    group_id && privacy == 'group'
  end

  def private_message?
    privacy == 'private'
  end

  def public?
    privacy == 'public'
  end

  def has_issue?
    issue_id
  end

  def first_message
    messages.order('id').first
  end

  def latest_activity_at
    messages.approved.empty? ? updated_at : messages.approved.maximum('messages.updated_at')
  end

  def latest_activity_by
    messages.approved.empty? ? created_by : messages.approved.last.created_by
  end

  def default_centre
    # returns location of (in order of preference)
    # 1. issue (even if it is deleted)
    # 2. group profile location (if the group has a profile and the profile has a location)
    # 3. the creators location (if they have one)
    # 4. nowhere in particular
    locatable = Issue.unscoped.find issue_id if issue_id
    locatable = locatable || (group.try :profile if group.try(:profile).try(:location)) || created_by.location
    locatable ? locatable.centre : SiteConfig.first.nowhere_location
  end

  def upcoming_deadline_messages
    messages.includes(:component).except(:order).joins('JOIN deadline_messages dm ON messages.component_id = dm.id').
      where("messages.component_type = 'DeadlineMessage'").
      where('dm.deadline >= current_date').
      where('messages.censored_at IS NULL').
      order('dm.deadline ASC')
  end

  def priority_for(user)
    user_priorities.find_by(user_id: user.id) || user_priorities.build(user: user)
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

  def to_icals
    upcoming_deadline_messages.map{ |message| message.component.to_ical }
  end

  def as_json(_options = nil)
    {
      id: id,
      issue_id: issue_id,
      created_by_id: created_by_id,
      created_by_name: created_by.profile.visibility == 'public' ? created_by.name : created_by.display_name,
      group_id: group_id,
      title: title,
      public_token: public_token,
      created_at: created_at,
      updated_at: updated_at,
      closed: closed,
    }
  end

  protected

  def set_public_token
    self.public_token = SecureRandom.hex(10)
  end

  def must_be_created_by_enabled_user
    return unless created_by
    errors.add :base, :disabled if created_by.disabled
  end

  def approve_related
    status_change = previous_changes.fetch(:status, [])
    if status_change.first != "approved" && status_change.last == "approved"
      ThreadSubscriber.subscribe_users self
      ThreadNotifier.notify_subscribers self, first_message

      NewThreadNotifier.notify_new_thread self
      SearchUpdater.update_type(self, :process_thread)
    end
    true
  end

  def add_subscribers
    add_subscriber(created_by)
    add_subscriber(user) if user
  end

  def add_auto_subscribers
    Resque.enqueue(ThreadAutoSubscriber, id, previous_changes)
  end
end
