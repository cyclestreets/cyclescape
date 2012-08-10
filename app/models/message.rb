# == Schema Information
#
# Table name: messages
#
#  id             :integer         not null, primary key
#  created_by_id  :integer         not null
#  thread_id      :integer         not null
#  body           :text            not null
#  component_id   :integer
#  component_type :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  deleted_at     :datetime
#  censored_at    :datetime
#

class Message < ActiveRecord::Base
  include FakeDestroy

  attr_accessible :body, :component

  belongs_to :thread, class_name: "MessageThread"
  belongs_to :created_by, class_name: "User"
  belongs_to :component, polymorphic: true, autosave: true

  before_validation :init_blank_body, on: :create, if: :component

  after_save :update_thread_search

  scope :recent, order("created_at DESC").limit(3)

  validates :created_by_id, presence: true
  validates :body, presence: true, unless: :component

  def censor!
    self.censored_at = Time.now
    save!
  end

  def censored?
    censored_at
  end

  def component_name
    (component ? component : self).class.model_name.underscore
  end

  def searchable_text
    component ? "#{body} #{component.searchable_text}" : body
  end

  def update_thread_search
    logger.debug(debug_msg("Updating thread search..."))
    SearchUpdater.update_thread(thread) if thread
    logger.debug(debug_msg("Finished updating thread search..."))
    true
  end

  protected

  def init_blank_body
    self.body ||= ""
  end

    # Formatting grabbed from ruby stdlib
  def timestamp_with_usec
    time = Time.now
    time.strftime("%Y-%m-%dT%H:%M:%S.") << "%06d " % time.usec
  end

  # Oh, rails, how I hate your shielding of Logger formatters from me
  def debug_msg(msg)
    "[#{timestamp_with_usec}] #{msg}"
  end
end
