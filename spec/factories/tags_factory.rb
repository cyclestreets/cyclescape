FactoryGirl.define do
  sequence(:tag, 'a') { |n| "tag#{n}" }

  factory :tag do
    name { FactoryGirl.generate(:tag) }

    factory :tag_with_icon do
      sequence(:icon) { |n| "icon-#{n}" }
    end
  end
end
