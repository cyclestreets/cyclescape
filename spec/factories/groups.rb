FactoryGirl.define do
  factory :group, :aliases => [:quahogcc] do
    name "Quahog Cycling Campaign"
    short_name "quahogcc"
    website "http://www.quahogcc.com"
    email "louis@quahogcc.com"

    trait :disabled do
      disabled_at { DateTime.now }
    end
  end
end
