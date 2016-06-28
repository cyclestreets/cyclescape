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
  dragonfly_accessor :photo do
    storage_options :generate_photo_path
  end

  validates :photo, presence: true

  def photo_medium
    photo.thumb('740x555>')
  end

  def photo_preview
    photo.thumb('500x375>')
  end

  def photo_thumbnail
    photo.thumb('50x50>')
  end

  def searchable_text
    [caption, description].join(' ')
  end

  protected

  def generate_photo_path
    hash = Digest::SHA1.file(photo.path).hexdigest
    {path: "message_photos/#{hash[0..2]}/#{hash[3..5]}/#{hash}"}
  end
end
