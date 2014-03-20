# == Schema Information
#
# Table name: thread_views
#
#  id        :integer          not null, primary key
#  user_id   :integer          not null
#  thread_id :integer          not null
#  viewed_at :datetime         not null
#

class ThreadView < ActiveRecord::Base
  belongs_to :user
  belongs_to :thread, class_name: 'MessageThread'

  validates :user, presence: true
  validates :thread, presence: true
  validates :viewed_at, presence: true
end
