# frozen_string_literal: true


class DeadlineMessage < MessageComponent
  validates :deadline, presence: true
  validates :title, presence: true
  belongs_to :thread, class_name: "MessageThread", inverse_of: :deadline_messages

  delegate :url_helpers, to: "Rails.application.routes"

  class << self
    def email_upcomming_deadlines!
      where(deadline: Time.zone.now..1.day.from_now).includes(:thread).find_each do |dm|
        thread = dm.thread
        thread.email_subscribers.active.each do |subscriber|
          Notifications.upcoming_thread_deadline(subscriber, thread, dm).deliver_now
        end
      end
    end
  end

  def formatted_deadline
    all_day ? deadline.to_date : deadline
  end

  def to_ical
    Icalendar::Event.new.tap do |e|
      e.dtstart     = Icalendar::Values::DateOrDateTime.new(formatted_deadline).call
      e.summary     = title
      e.description = thread.title
      e.url         = url_helpers
                      .thread_url(self,
                                  anchor: ActionView::RecordIdentifier.dom_id(message),
                                  host: Rails.application.config.action_mailer.default_url_options[:host])
    end
  end
end

# == Schema Information
#
# Table name: deadline_messages
#
#  id                :integer          not null, primary key
#  all_day           :boolean          default(FALSE), not null
#  deadline          :datetime         not null
#  invalidated_at    :datetime
#  title             :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  created_by_id     :integer          not null
#  invalidated_by_id :integer
#  message_id        :integer          not null
#  thread_id         :integer          not null
#
# Indexes
#
#  index_deadline_messages_on_created_by_id  (created_by_id)
#  index_deadline_messages_on_message_id     (message_id)
#  index_deadline_messages_on_thread_id      (thread_id)
#
