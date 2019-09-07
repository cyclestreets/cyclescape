# frozen_string_literal: true



class MessageThreadClose < ApplicationRecord
  belongs_to :user
  belongs_to :message_thread
end

# == Schema Information
#
# Table name: message_thread_closes
#
#  id                :integer          not null, primary key
#  event             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  message_thread_id :integer
#  user_id           :integer
#
# Indexes
#
#  index_message_thread_closes_on_message_thread_id  (message_thread_id)
#  index_message_thread_closes_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (message_thread_id => message_threads.id)
#  fk_rails_...  (user_id => users.id)
#
