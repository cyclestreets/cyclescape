FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "Campaign Group #{n}" }
    sequence(:short_name) { |n| "cc#{n}" }
    sequence(:website) { |n| "http://www.cc#{n}.com" }
    sequence(:email) { |n| "admin@cc#{n}.com" }

    trait :with_profile do
      association :profile, factory: :group_profile
    end

    trait :disabled do
      disabled_at { DateTime.now }
    end

    factory :quahogcc do
      name 'Quahog Cycling Campaign'
      short_name 'quahogcc'
      website 'http://www.quahogcc.com'
      email 'louis@quahogcc.com'
    end
  end
end
