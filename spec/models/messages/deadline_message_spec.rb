# frozen_string_literal: true

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

require "spec_helper"

describe DeadlineMessage do
  describe "associations" do
    it { is_expected.to belong_to(:thread) }
    it { is_expected.to belong_to(:message) }
    it { is_expected.to belong_to(:created_by) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:deadline) }
    it { is_expected.to validate_presence_of(:title) }
  end

  it "should email about deadlines" do
    dm = create :deadline_message, deadline: 5.hours.from_now, title: "Do not miss me!"
    deleted = create :deadline_message, deadline: 5.hours.from_now, title: "thread deleted"
    thread = dm.thread
    deleted.thread.destroy! # it shouldn't crash with deleted threads
    subscriptions = create_list :thread_subscription, 2, thread: thread
    user = subscriptions.first.user
    user.prefs.update_column(:email_status_id, 1)

    user_disabled = subscriptions.last.user
    user_disabled.prefs.update_column(:email_status_id, 1)
    user_disabled.update_column(:disabled_at, Time.current)

    expect { described_class.email_upcomming_deadlines! }.to change { all_emails.count }.by(1)
    email = all_emails.last
    expect(email.to).to include(user.email)
    expect(email.body).to include("upcoming deadline")
    expect(email.body).to include("Do not miss me!")
    expect(email.subject).to include("Upcoming deadline")
    expect(email.body).to include(dm.deadline.in_time_zone("London").to_formatted_s(:long_ordinal))
  end

  it ".to_ical" do
    subject = create :deadline_message
    expect(subject.to_ical.dtstart).to eq subject.deadline
  end
end
