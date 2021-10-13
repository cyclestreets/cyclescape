# frozen_string_literal: true

class UserThreadFavourite < ApplicationRecord
  belongs_to :user
  belongs_to :thread, class_name: "MessageThread", inverse_of: :user_favourites

  validates :user, uniqueness: { scope: :thread_id }
end

# == Schema Information
#
# Table name: user_thread_favourites
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  thread_id  :bigint(8)        not null
#  user_id    :bigint(8)        not null
#
# Indexes
#
#  index_user_thread_favourites_on_thread_id_and_user_id  (thread_id,user_id) UNIQUE
#  index_user_thread_favourites_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (thread_id => message_threads.id)
#  fk_rails_...  (user_id => users.id)
#
