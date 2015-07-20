FactoryGirl.define do
  factory :user_profile do
    user
    picture { Pathname.new(File.join(%w(spec support images abstract-100-100.jpg))) }
    website 'http://www.allaboutmyexcitingadventures.com'
    about 'About the exciting adventures of me!'
  end
end
