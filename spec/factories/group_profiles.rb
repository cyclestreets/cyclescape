# == Schema Information
#
# Table name: group_profiles
#
#  id                   :integer          not null, primary key
#  group_id             :integer          not null
#  description          :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  location             :spatial          geometry, 4326
#  joining_instructions :text
#
# Indexes
#
#  index_group_profiles_on_group_id  (group_id)
#  index_group_profiles_on_location  (location)
#

FactoryGirl.define do
  factory :group_profile do
    description 'This is a group of people who want to do some stuff. It probably involves cycling, but you can never be certain about that'
    joining_instructions 'Jump up get down stand up turn around. Twice. While cycling backwards'
    location 'POINT(-122 47)'
    association :group, factory: :group

    trait :with_picture do
      picture { Pathname.new(File.join(%w(spec support images abstract-100-100.jpg))) }
    end

    factory :small_group_profile do
      location 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))'
    end

    factory :big_group_profile do
      location 'POLYGON ((0 0, 0 100, 100 100, 100 0, 0 0))'
    end

    factory :quahogcc_group_profile do
      association :group, factory: :quahogcc
      location 'POLYGON ((-0.048337826538099 52.288247679276, -0.095029721069341 52.334425101058, -0.0064524505615302 52.370493901594, 0.084528079223625 52.301266191436, 0.26065265197753 52.294127481182, 0.26751910705777 52.191539167527, 0.22906695861468 52.15279673993, 0.18100177306972 52.101368865428, 0.12469684143375 52.097994471963, 0.073885073849465 52.148583573398, -0.13622845154113 52.2142635765, -0.048337826538099 52.288247679276))'
    end
  end
end
