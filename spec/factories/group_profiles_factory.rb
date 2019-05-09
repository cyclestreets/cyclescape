# frozen_string_literal: true

FactoryBot.define do
  factory :group_profile do
    description "This is a group of people who want to do some stuff. It probably involves cycling, but you can never be certain about that"
    joining_instructions "Jump up get down stand up turn around. Twice. While cycling backwards"
    location "POINT(-122 47)"
    new_user_email "Hi"
    association :group, factory: :group, strategy: :build

    trait :with_picture do
      picture { Pathname.new(File.join(%w[spec support images abstract-100-100.jpg])) }
    end

    factory :small_group_profile do
      location "POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))"
    end

    factory :big_group_profile do
      location "POLYGON ((0 0, 0 100, 100 100, 100 0, 0 0))"
    end

    factory :quahogcc_group_profile do
      association :group, factory: :quahogcc, strategy: :build
      location "POLYGON ((-0.048337826538099 52.288247679276, -0.095029721069341 52.334425101058, -0.0064524505615302 52.370493901594, 0.084528079223625 52.301266191436, 0.26065265197753 52.294127481182, 0.26751910705777 52.191539167527, 0.22906695861468 52.15279673993, 0.18100177306972 52.101368865428, 0.12469684143375 52.097994471963, 0.073885073849465 52.148583573398, -0.13622845154113 52.2142635765, -0.048337826538099 52.288247679276))"
    end
  end
end
