# frozen_string_literal: true

class ThreadLeaderMessage < MessageComponent
  belongs_to :unleading, class_name: "ThreadLeaderMessage"

  scope :active, -> { where(active: true, unleading: nil) }

  validate :user_ownes_unleading

  before_create :deactivae_unleading

  class << self
    def already_leading(user, thread)
      active.find_by(thread: thread, created_by: user)
    end
  end

  def leading?
    !withdrawing?
  end

  def withdrawing?
    unleading_id?
  end

  private

  def user_ownes_unleading
    return if !unleading_id || unleading.created_by_id == created_by_id

    errors.add :base, :not_owing_leader_message
  end

  def deactivae_unleading
    unleading&.update(active: false)
  end
end

# == Schema Information
#
# Table name: thread_leader_messages
#
#  id            :integer          not null, primary key
#  active        :boolean          default(TRUE), not null
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer
#  message_id    :integer
#  thread_id     :integer
#  unleading_id  :integer
#
# Indexes
#
#  index_thread_leader_messages_on_created_by_id  (created_by_id)
#  index_thread_leader_messages_on_message_id     (message_id)
#  index_thread_leader_messages_on_thread_id      (thread_id)
#  index_thread_leader_messages_on_unleading_id   (unleading_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (message_id => messages.id)
#  fk_rails_...  (thread_id => message_threads.id)
#  fk_rails_...  (unleading_id => thread_leader_messages.id)
#
