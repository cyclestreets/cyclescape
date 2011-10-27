class UserProfile < ActiveRecord::Base
  image_accessor :picture do
    storage_path :generate_picture_path
  end

  belongs_to :user

  validates_property :mime_type, of: :picture, in: %w(image/jpeg image/png image/gif)

  def picture_thumbnail
    picture.thumb("50x50>")
  end

  protected

  def generate_picture_path
    hash = Digest::SHA1.file(picture.path).hexdigest
    "profile_pictures/#{hash[0..2]}/#{hash[3..5]}/#{hash}"
  end
end
