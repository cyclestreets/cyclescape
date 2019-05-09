# frozen_string_literal: true

FactoryBot.define do
  sequence(:tag, "a") { |n| "tag#{n}" }

  factory :tag do
    name { FactoryBot.generate(:tag) }

    factory :tag_with_icon do
      sequence(:icon) { |n| "icon-#{n}" }
    end
  end
end
