# frozen_string_literal: true

class PollVote < ApplicationRecord
  belongs_to :user
  belongs_to :poll_option, touch: true
end

# == Schema Information
#
# Table name: poll_votes
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  poll_option_id :bigint(8)        not null
#  user_id        :bigint(8)        not null
#
# Indexes
#
#  index_poll_votes_on_poll_option_id              (poll_option_id)
#  index_poll_votes_on_user_id                     (user_id)
#  index_poll_votes_on_user_id_and_poll_option_id  (user_id,poll_option_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (poll_option_id => poll_options.id)
#  fk_rails_...  (user_id => users.id)
#
