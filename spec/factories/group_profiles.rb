FactoryGirl.define do
  factory :group_profile do
    description "This is a group of people who want to do some stuff. It probably involves cycling, but you can never be certain about that"
    location "POINT(-122 47)"
    association :group, factory: :group

    factory :small_group_profile do
      location "POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))"
    end

    factory :big_group_profile do
      location "POLYGON ((0 0, 0 100, 100 100, 100 0, 0 0))"
    end
  end
end