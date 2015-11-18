# == Schema Information
#
# Table name: deadline_messages
#
#  id                :integer          not null, primary key
#  thread_id         :integer          not null
#  message_id        :integer          not null
#  created_by_id     :integer          not null
#  deadline          :datetime         not null
#  title             :string(255)      not null
#  created_at        :datetime
#  invalidated_at    :datetime
#  invalidated_by_id :integer
#

class DeadlineMessage < MessageComponent
  validates :deadline, presence: true
  validates :title, presence: true
  belongs_to :thread, class_name: 'MessageThread', inverse_of: :deadline_messages

  delegate :url_helpers, to: "Rails.application.routes"

  class << self
    def email_upcomming_deadlines!
      where(deadline: Time.zone.now..1.day.from_now).includes(:thread).find_each do |dm|
        thread = dm.thread
        thread.email_subscribers.each do |subscriber|
          Notifications.upcoming_thread_deadline(subscriber, thread, dm.deadline).deliver_now
        end
      end
    end
  end

  def to_ical
    Icalendar::Event.new.tap do |e|
      e.dtstart     = Icalendar::Values::Date.new(deadline)
      e.summary     = title
      e.description = thread.title
      e.url         = url_helpers.
        thread_url(self,
                   anchor: ActionView::RecordIdentifier.dom_id(message),
                   host: Rails.application.config.action_mailer.default_url_options[:host]
                  )
    end
  end
end
