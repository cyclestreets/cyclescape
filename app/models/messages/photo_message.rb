# frozen_string_literal: true


class PhotoMessage < MessageComponent
  include Photo

  validates :photo, presence: true

  def searchable_text
    [caption, description].join(" ")
  end

  private

  def storage_path
    "message_photos"
  end
end

# == Schema Information
#
# Table name: photo_messages
#
#  id            :integer          not null, primary key
#  caption       :string(255)
#  description   :text
#  photo_name    :string
#  photo_uid     :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime
#  created_by_id :integer          not null
#  message_id    :integer          not null
#  thread_id     :integer          not null
#
# Indexes
#
#  index_photo_messages_on_created_by_id  (created_by_id)
#  index_photo_messages_on_message_id     (message_id)
#  index_photo_messages_on_thread_id      (thread_id)
#
