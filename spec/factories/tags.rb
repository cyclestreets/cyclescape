FactoryGirl.define do
  sequence(:tag, "a") {|n| "tag#{n}" } 

  factory :tag do
    name { FactoryGirl.generate(:tag) }
  end
end
