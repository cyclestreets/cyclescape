# frozen_string_literal: true

class PollOption < ApplicationRecord
  belongs_to :poll_message, touch: true

  has_many :poll_votes, dependent: :destroy

  validates :option, presence: true

  delegate :thread, to: :poll_message
end

# == Schema Information
#
# Table name: poll_options
#
#  id              :bigint(8)        not null, primary key
#  option          :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  poll_message_id :bigint(8)        not null
#
# Indexes
#
#  index_poll_options_on_poll_message_id  (poll_message_id)
#
# Foreign Keys
#
#  fk_rails_...  (poll_message_id => poll_messages.id)
#
