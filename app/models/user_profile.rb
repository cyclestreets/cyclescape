# == Schema Information
#
# Table name: user_profiles
#
#  id          :integer         not null, primary key
#  user_id     :integer         not null
#  picture_uid :string(255)
#  website     :string(255)
#  about       :text
#

class UserProfile < ActiveRecord::Base
  attr_accessible :picture, :retained_picture, :remove_picture, :website, :about

  image_accessor :picture do
    storage_path :generate_picture_path
  end

  belongs_to :user

  validates :website, url: true
  validates_property :mime_type, of: :picture, in: %w(image/jpeg image/png image/gif)

  def website=(val)
    write_attribute(:website, AttributeNormaliser::URL.new(val).normalise)
  end

  def picture_thumbnail
    picture.thumb("50x50>")
  end

  protected

  def generate_picture_path
    hash = Digest::SHA1.file(picture.path).hexdigest
    "profile_pictures/#{hash[0..2]}/#{hash[3..5]}/#{hash}"
  end
end
