FactoryGirl.define do
  factory :group_profile do
    description "This is a group of people who want to do some stuff. It probably involves cycling, but you can never be certain about that"
    location "POINT(-122 47)"
    association :group, factory: :group
  end
end