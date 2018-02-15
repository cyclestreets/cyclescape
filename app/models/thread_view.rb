# frozen_string_literal: true

# == Schema Information
#
# Table name: thread_views
#
#  id        :integer          not null, primary key
#  user_id   :integer          not null
#  thread_id :integer          not null
#  viewed_at :datetime         not null
#
# Indexes
#
#  index_thread_views_on_user_id                (user_id)
#  index_thread_views_on_user_id_and_thread_id  (user_id,thread_id) UNIQUE
#

class ThreadView < ActiveRecord::Base
  belongs_to :user, inverse_of: :thread_views
  belongs_to :thread, class_name: 'MessageThread'

  validates :user, presence: true
  validates :thread, presence: true
  validates :viewed_at, presence: true
end
