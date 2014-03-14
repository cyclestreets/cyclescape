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

class MessageThread < ActiveRecord::Base
  include FakeDestroy
  include Taggable

  attr_accessible :title, :privacy, :group_id, :issue_id, :tags_string

  acts_as_indexed :fields => [:title, :messages_text, :tags_string]

  ALLOWED_PRIVACY = %w(public group committee)

  belongs_to :created_by, class_name: "User"
  belongs_to :group
  belongs_to :issue
  has_many :messages, foreign_key: "thread_id", autosave: true, order: 'created_at ASC'
  has_many :subscriptions, class_name: "ThreadSubscription", foreign_key: "thread_id", conditions: {deleted_at: nil}
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :participants, through: :messages, source: :created_by, uniq: true
  has_many :user_priorities, class_name: "UserThreadPriority", foreign_key: "thread_id"
  has_and_belongs_to_many :tags, join_table: "message_thread_tags", foreign_key: "thread_id"
  has_one :latest_message, foreign_key: "thread_id", order: "created_at DESC", class_name: "Message"

  scope :public, where("privacy = 'public'")
  scope :private, where("privacy = 'group'")
  scope :with_issue, where("issue_id IS NOT NULL")
  scope :without_issue, where("issue_id IS NULL")
  default_scope where(deleted_at: nil)

  before_validation :set_public_token, on: :create

  validates :title, :state, :created_by_id, presence: true
  validates :privacy, inclusion: {in: ALLOWED_PRIVACY}

  state_machine :state, initial: :new do
  end

  def self.non_committee_privacies_map
    (ALLOWED_PRIVACY - ["committee"]).map {|n| [I18n.t(".thread_privacy_options.#{n.to_s}"), n] }
  end

  def self.privacies_map
    ALLOWED_PRIVACY.map {|n| [I18n.t(".thread_privacy_options.#{n.to_s}"), n] }
  end

  def self.with_messages_from(user)
    where "EXISTS (SELECT id FROM messages m WHERE thread_id = message_threads.id AND m.created_by_id = ?)", user
  end

  def self.order_by_latest_message
    rel = joins("JOIN (SELECT thread_id, MAX(created_at) AS created_at FROM messages m GROUP BY thread_id)" \
                "AS latest ON latest.thread_id = message_threads.id")
    rel.order("latest.created_at DESC")
  end

  def self.with_upcoming_deadlines
    rel = joins("JOIN (SELECT m.thread_id, MIN(deadline) AS deadline
                  FROM messages m
                  JOIN deadline_messages dm ON m.component_id = dm.id
                  WHERE m.component_type = 'DeadlineMessage'
                    AND dm.deadline >= current_date
                    AND m.censored_at IS NULL
                  GROUP BY m.thread_id)
                AS m2
                ON m2.thread_id = message_threads.id")
    rel.order("m2.deadline ASC")
  end

  def add_subscriber(user)
    found = user.thread_subscriptions.to(self)
    if found
      # Reset the subscription
      found.undelete!
      found
    else
      subscriptions.create({user: user}, without_protection: true)
    end
  end

  def add_messages_from_email!(mail)
    from_address = mail.message.header[:from].addresses.first
    from_name = mail.message.header[:from].display_names.first

    user = User.find_or_invite(from_address, from_name)
    raise "Invalid user: #{from_address.inspect} #{from_name.inspect}" if user.nil?

    # For multipart messages we pull out the text/plain content
    text = if mail.message.multipart?
      mail.message.text_part.decoded
    else
      mail.message.decoded
    end

    parsed = EmailReplyParser.read(text)
    stripped = parsed.fragments.select {|f| !f.hidden? }.join

    m = []

    m << messages.create!({body: stripped, created_by: user}, without_protection: true)

    # Attachments
    mail.message.attachments.each do |attachment|
      if attachment.content_type.start_with?('image/')
        component = PhotoMessage.new(photo: attachment.body.decoded, caption: attachment.filename)
      else
        component = DocumentMessage.new(file: attachment.body.decoded, title: attachment.filename)
      end
      message = messages.build({created_by: user}, without_protection: true)
      component.thread = self
      component.message = message
      component.created_by = user
      message.component = component
      message.save!
      m << message
    end

    return m
  end

  def email_subscribers
    subscribers.joins(:prefs).where(user_prefs: {:enable_email => true})
  end

  def private_to_committee?
    group_id && privacy == "committee"
  end

  def private_to_group?
    group_id && privacy == "group"
  end

  def public?
    privacy == "public"
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
    messages.order("id").first
  end

  def latest_activity_at
    messages.empty? ? updated_at : messages.last.updated_at
  end

  def latest_activity_by
    messages.empty? ? created_by : messages.last.created_by
  end

  def upcoming_deadline_messages
    messages.except(:order).joins("JOIN deadline_messages dm ON messages.component_id = dm.id").
      where("messages.component_type = 'DeadlineMessage'").
      where("dm.deadline >= current_date").
      where("messages.censored_at IS NULL").
      order("dm.deadline ASC")
  end

  def priority_for(user)
    user_priorities.where(user_id: user.id).first
  end

  def messages_text
    messages.all.map { |m| m.searchable_text }.join(" ")
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
end
