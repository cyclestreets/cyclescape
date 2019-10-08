# frozen_string_literal: true

class ActionMessage < MessageComponent
  self.ignored_columns = %w[completing_message_type] # TODO: was polymorphic, need to remove

  belongs_to :completing_message, class_name: "Message"

  validates :description, presence: true

  def completed?
    completing_message.try(:message).try(:approved?) || completing_message
  end
end

# == Schema Information
#
# Table name: action_messages
#
#  id                      :integer          not null, primary key
#  completing_message_type :string
#  description             :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  completing_message_id   :integer
#  created_by_id           :integer          not null
#  message_id              :integer          not null
#  thread_id               :integer          not null
#
# Indexes
#
#  index_action_messages_on_completing_message_id  (completing_message_id)
#  index_action_messages_on_created_by_id          (created_by_id)
#  index_action_messages_on_message_id             (message_id)
#  index_action_messages_on_thread_id              (thread_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (message_id => messages.id)
#  fk_rails_...  (thread_id => message_threads.id)
#
