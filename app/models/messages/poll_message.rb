# frozen_string_literal: true

class PollMessage < MessageComponent
  belongs_to :message, touch: true
  has_many :poll_options, dependent: :destroy
  has_many :poll_votes, through: :poll_options

  validates :question, presence: true
  validates :poll_options, length: { minimum: 2, message: "must have at least 2 options" }

  accepts_nested_attributes_for :poll_options, reject_if: :all_blank
end

# == Schema Information
#
# Table name: poll_messages
#
#  id            :bigint(8)        not null, primary key
#  question      :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint(8)        not null
#  message_id    :bigint(8)        not null
#  thread_id     :bigint(8)        not null
#
# Indexes
#
#  index_poll_messages_on_created_by_id  (created_by_id)
#  index_poll_messages_on_message_id     (message_id)
#  index_poll_messages_on_thread_id      (thread_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (message_id => messages.id)
#  fk_rails_...  (thread_id => message_threads.id)
#
