class PhotoMessage < MessageComponent
  # Core associations defined in MessageComponent

  image_accessor :photo

  validates :photo, presence: true
end
