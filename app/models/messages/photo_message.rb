# == Schema Information
#
# Table name: photo_messages
#
#  id            :integer          not null, primary key
#  thread_id     :integer          not null
#  message_id    :integer          not null
#  created_by_id :integer          not null
#  photo_uid     :string(255)      not null
#  caption       :string(255)
#  description   :text
#  created_at    :datetime         not null
#

class PhotoMessage < MessageComponent
  include Photo

  validates :photo, presence: true

  def searchable_text
    [caption, description].join(' ')
  end

  private

  def storage_path
    "message_photos"
  end
end
