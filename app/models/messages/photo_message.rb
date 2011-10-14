class PhotoMessage < MessageComponent
  # Core associations defined in MessageComponent

  image_accessor :photo do
    storage_path :generate_photo_path
  end

  validates :photo, presence: true

  protected

  def generate_photo_path
    hash = Digest::SHA1.file(photo.path).hexdigest
    "message_photos/#{hash[0..2]}/#{hash[3..5]}/#{hash}"
  end
end
