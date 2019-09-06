# frozen_string_literal: true

FactoryBot.define do
  factory :planning_application do
    sequence(:uid) { |n| "a/b/c/#{n}" }
    address { "15 Foo Street, Placeville" }
    postcode { "SW1A 1AA" }
    description { "Add twelve additional storeys to the garden shed" }
    authority_name { "Placeville County Council" }
    url { "http://example.net/gov/planning_applications/0013-150-1553" }
    location { "POINT(-122 47)" }

    trait :with_issue do
      association :issue
    end
  end
end
