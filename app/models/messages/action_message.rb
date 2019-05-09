# frozen_string_literal: true

class ActionMessage < MessageComponent
  belongs_to :completing_message, polymorphic: true

  validates :description, presence: true

  def completed?
    completing_message.try(:message).try(:approved?)
  end
end
