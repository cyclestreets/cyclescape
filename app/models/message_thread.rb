# frozen_string_literal: true

class MessageThread < ApplicationRecord
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

  PUBLIC = "public" # Anyone can see
  GROUP = "group" # Only visible to members of the group
  COMMITTEE = "committee" # Only visible to committee members of the group
  PRIVATE = "private" # Only visible between two users

  ALL_ALLOWED_PRIVACY = [PUBLIC, GROUP, COMMITTEE, PRIVATE].freeze
  ALLOWED_PRIVACY = [PUBLIC, GROUP, COMMITTEE].freeze
  NON_COMMITTEE_ALLOWED_PRIVACY = [PUBLIC, GROUP].freeze

  belongs_to :created_by, -> { with_deleted }, class_name: "User"
  belongs_to :group, inverse_of: :threads, counter_cache: true
  belongs_to :issue, inverse_of: :threads, optional: true
  belongs_to :user, inverse_of: :private_threads
  has_many :messages, -> { ordered_for_thread_view }, foreign_key: "thread_id", autosave: true, inverse_of: :thread
  has_many :subscriptions, -> { where(deleted_at: nil) }, class_name: "ThreadSubscription", foreign_key: "thread_id", inverse_of: :thread
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :participants, -> { distinct }, through: :messages, source: :created_by
  has_many :user_favourites, class_name: "UserThreadFavourite", foreign_key: "thread_id", inverse_of: :thread
  has_many :message_thread_closes, -> { order(:created_at) }, dependent: :destroy
  has_many :closed_by, through: :message_thread_closes, source: :user
  has_many :map_messages, foreign_key: :thread_id, inverse_of: :thread
  has_many :action_messages, foreign_key: :thread_id, inverse_of: :thread
  has_many :deadline_messages, foreign_key: :thread_id, inverse_of: :thread
  has_many :thread_leader_messages, -> { active }, dependent: :destroy, foreign_key: :thread_id
  has_many :poll_messages, foreign_key: :thread_id, dependent: :restrict_with_error, inverse_of: :thread
  has_many :leaders, through: :thread_leader_messages, source: :created_by, inverse_of: :leading_threads
  has_many :thread_views, inverse_of: :thread, foreign_key: :thread_id, dependent: :destroy
  has_and_belongs_to_many :tags, join_table: "message_thread_tags", foreign_key: :thread_id
  has_one :latest_message, -> { order("created_at DESC").approved }, foreign_key: :thread_id, class_name: "Message"

  scope :is_public,        -> { where(privacy: "public") }
  scope :with_issue,       -> { where.not(issue_id: nil) }
  scope :without_issue,    -> { where(issue_id: nil) }
  scope :approved,         -> { where(status: "approved") }
  scope :mod_queued,       -> { where(status: "mod_queued") }
  scope :is_private,       -> { where(privacy: PRIVATE) }
  scope :is_open,          -> { where(closed: false) }
  scope :private_for, lambda { |usr|
    is_private.where(arel_table[:created_by_id].eq(usr.id).or(arel_table[:user_id].eq(usr.id)))
  }
  scope :unviewed_for, lambda { |usr|
    return none unless usr

    messages = Message.arel_table
    thread_views = ThreadView.arel_table
    approved.joins(:latest_message,
                   arel_table.join(thread_views, Arel::Nodes::OuterJoin)
      .on(thread_views[:thread_id].eq(arel_table[:id]), thread_views[:user_id].eq(usr.id)).join_sources)
            .merge(Message.approved)
            .where(messages[:created_at].gt(thread_views[:viewed_at]).or(thread_views[:viewed_at].eq(nil)))
  }
  scope :after_date, ->(date) { where(arel_table[:created_at].gteq(date)) }
  scope :before_date, ->(date) { where(arel_table[:created_at].lteq(date)) }
  scope :after_id, ->(id) { where(arel_table[:id].gt(id)) }
  scope :favourite_for, ->(user) { join(:user_favourites).merge(UserThreadFavourite.where(user: user)) }
  scope :ordered_by_nos_of_messages, -> { joins(:messages).merge(Message.approved).group(column_names).order(Arel.sql("count(*) desc")) }

  default_scope { where(deleted_at: nil) }

  before_validation :set_public_token, on: :create
  after_create      :add_subscribers
  after_commit      :add_auto_subscribers
  after_commit      :approve_related

  validates :title, :created_by, presence: true
  validates :privacy, inclusion: { in: ALL_ALLOWED_PRIVACY }
  validates :group, presence: true, if: ->(thread) { thread.privacy == GROUP }
  validate :must_be_created_by_enabled_user, on: :create
  validate :ensure_group_privacy_allowed

  attr_writer :updated_by

  aasm column: "status", requires_lock: true do
    state :mod_queued, initial: true
    state :approved

    event :approve do
      transitions to: :approved
    end
  end

  class << self
    def unviewed_message_counts(usr)
      return none unless usr

      thread_views = ThreadView.where(user: usr, thread_id: all).select(:thread_id, :viewed_at).to_a
      (ids - thread_views.map(&:thread_id)).each do |thread_id|
        thread_views.push(ThreadView.new(thread_id: thread_id, viewed_at: Time.zone.at(0)))
      end
      where_sql = thread_views.map { |_| "(messages.thread_id = ? and messages.created_at > ?)" }.join(" OR ")
      joins(:messages)
        .merge(Message.approved)
        .where(where_sql, *thread_views.map { |v| [v.thread_id, v.viewed_at] }.flatten)
        .group(:id)
        .pluck(:id, Arel.sql("count(*)"))
    end

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
      where "EXISTS (SELECT id FROM messages m WHERE thread_id = message_threads.id AND m.created_by_id = ?)", user
    end

    def order_by_latest_message
      rel = joins("JOIN (SELECT thread_id, MAX(created_at) AS created_at FROM messages m WHERE m.status in (NULL, 'approved') GROUP BY thread_id )" \
                  "AS latest ON latest.thread_id = message_threads.id")
      rel.order("latest.created_at DESC")
    end

    def with_upcoming_deadlines
      cols = MessageThread.column_names.map { |cn| "message_threads.#{cn}" }
      joins(messages: :deadline_messages)
        .where("deadline_messages.deadline >= ?", 1.hour.ago) # To give a bit of time after the event might have started
        .where(messages: {censored_at: nil})
        .order(Arel.sql("MIN(deadline_messages.deadline) ASC"))
        .group(cols.join(", "))
        .select((cols + ["MIN(deadline_messages.deadline)"]).join(", "))
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

  def other_user(current_user)
    ([user, created_by] - [current_user]).first
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

  def display_id
    "##{id}"
  end

  def close_by!(user)
    message_thread_closes.create(user: user, event: "closed") if update(closed: true)
  end

  def open_by!(user)
    message_thread_closes.create(user: user, event: "opened") if update(closed: false)
  end

  def add_subscriber(user)
    return true if user.thread_subscriptions.to(self).try(:undelete!)

    begin
      subscriptions.find_or_create_by!(user: user, deleted_at: nil)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  def add_messages_from_email!(mail, in_reply_to, try_html: true)
    from_address = mail.message.header[:from].addresses.first
    from_name = mail.message.header[:from].display_names.first
    h = ActionController::Base.helpers

    user = User.find_or_invite(from_address, from_name)
    raise "Invalid user: #{from_address.inspect} #{from_name.inspect}" if user.nil?

    text = if try_html && mail.message.html_part
             # For multipart messages we pull out the html part content and use Javascript to remove the signature
             stripped = `./lib/sig_strip.js #{Shellwords.escape(mail.message.html_part.decoded)}`
             body = Loofah.document(stripped).at_xpath("//body").to_s.tr("\r", "")
             div_to_p = Loofah::Scrubber.new do |node|
               node.name = "p" if %w[div body].include?(node.name)
             end
             Loofah.scrub_fragment(body, div_to_p).to_s
           else
             # When there is no HTML we get the text part or just the message and use EmailReplyParser to remove the signature
             body = (mail.message.text_part || mail.message).decoded
             parsed = EmailReplyParser.read(body)

             stripped = parsed.fragments.reject(&:hidden?).join("\n")
             h.simple_format(stripped)
           end
    text = h.auto_link(text) # This also sanatizes the HTML

    open_by!(user) if closed
    new_message = messages.build(
      body: text, created_by: user, in_reply_to: in_reply_to, inbound_mail: mail
    )

    if new_message.body.blank?
      return add_messages_from_email!(mail, in_reply_to, try_html: false)
    end

    # Attachments
    mail.message.attachments.each do |attachment|
      next if attachment.content_type.include?("pgp-signature") || attachment.content_type.include?("pkcs7")

      component = if attachment.content_type.start_with?("image/")
                    new_message.photo_messages.build(photo: attachment.body.decoded, caption: attachment.filename)
                  else
                    new_message.document_messages.build(file: attachment.body.decoded, title: attachment.filename)
                  end
      component.thread     = self
      component.created_by = user
    end
    new_message.tap(&:save!).skip_mod_queue!
  end

  def email_subscribers
    subscribers.joins(:prefs).where(user_prefs: { email_status_id: 1 })
  end

  def private_to_committee?
    group_id && privacy == COMMITTEE
  end

  def private_to_group?
    group_id && privacy == GROUP
  end

  def private_message?
    privacy == PRIVATE
  end

  def public?
    privacy == PUBLIC
  end

  def has_issue?
    issue_id
  end

  def first_message
    messages.order("id").first
  end

  def latest_activity_at
    latest_activity.updated_at
  end

  def latest_activity_by
    latest_activity.created_by
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
    messages
      .joins(:deadline_messages)
      .where("deadline_messages.deadline >= ?", 1.hour.ago) # To give a bit of time after the deadline has finished
      .where(censored_at: nil)
      .order("deadline_messages.deadline ASC")
  end

  def favourite_for(user)
    user_favourites.find_or_initialize_by(user: user)
  end

  def messages_text
    messages.approved.map(&:searchable_text).join(" ")
  end

  # for auth checks
  def group_committee_members
    group.try(:committee_members) || User.none
  end

  def to_icals
    upcoming_deadline_messages.includes(:deadline_messages).flat_map do |message|
      message.deadline_messages.map(&:to_ical)
    end
  end

  def as_json(_options = nil)
    {
      id: id,
      issue_id: issue_id,
      created_by_id: created_by_id,
      created_by_name: created_by.profile.visibility == "public" ? created_by.name : created_by.display_name,
      group_id: group_id,
      title: title,
      public_token: public_token,
      created_at: created_at,
      updated_at: updated_at,
      closed: closed
    }
  end

  def created_at_as_i
    created_at.to_i
  end

  protected

  def set_public_token
    self.public_token = SecureRandom.hex(10)
  end

  def must_be_created_by_enabled_user
    return unless created_by

    errors.add :base, :disabled if created_by.disabled
  end

  def ensure_group_privacy_allowed
    user_performing_change = @updated_by || created_by
    return unless user_performing_change && group

    return if group.thread_privacy_options_for(user_performing_change).include?(privacy)

    errors.add :privacy, :inclusion
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

  def latest_activity
    @latest_activity ||= messages.approved.order(updated_at: :asc).last || self
  end
end

# == Schema Information
#
# Table name: message_threads
#
#  id            :integer          not null, primary key
#  closed        :boolean          default(FALSE), not null
#  deleted_at    :datetime
#  privacy       :string(255)      not null
#  public_token  :string(255)
#  status        :string
#  title         :string(255)      not null
#  zzz_state     :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer          not null
#  group_id      :integer
#  issue_id      :integer
#  user_id       :integer
#
# Indexes
#
#  index_message_threads_on_created_by_id  (created_by_id)
#  index_message_threads_on_group_id       (group_id)
#  index_message_threads_on_issue_id       (issue_id)
#  index_message_threads_on_public_token   (public_token) UNIQUE
#  index_message_threads_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
