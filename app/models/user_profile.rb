class UserProfile < ActiveRecord::Base
  image_accessor :picture do
    storage_path :generate_picture_path
  end

  belongs_to :user

  protected

  def generate_picture_path
    hash = Digest::SHA1.file(picture.path).hexdigest
    "attachments/user_profile/#{hash[0..6]}/#{hash}"
  end
end
