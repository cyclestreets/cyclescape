class MessageComponent < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :message, inverse_of: :component
  belongs_to :thread, class_name: 'MessageThread'
  belongs_to :created_by, class_name: 'User'

  # Override this per-component
  def searchable_text
    ''
  end

  def notification_name
    "new_#{self.class.name.underscore}".to_sym
  end
end
