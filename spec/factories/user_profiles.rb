# == Schema Information
#
# Table name: user_profiles
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  picture_uid :string(255)
#  website     :string(255)
#  about       :text
#
# Indexes
#
#  index_user_profiles_on_user_id  (user_id)
#

FactoryGirl.define do
  factory :user_profile do
    user
    picture { Pathname.new(File.join(%w(spec support images abstract-100-100.jpg))) }
    website 'http://www.allaboutmyexcitingadventures.com'
    about 'About the exciting adventures of me!'
  end
end
