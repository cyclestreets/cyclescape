# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:full_name) { |n| "User #{n}" }
    sequence(:password) { |n| "password#{n}" }
    sequence(:password_confirmation) { |n| "password#{n}" }
    after(:build, &:skip_confirmation!)
    approved { true }

    trait :admin do
      role { "admin" }
    end

    trait :with_profile do
      after(:build) { |u| FactoryBot.build(:user_profile, user: u) }
    end

    trait :with_location do
      after(:build) { |u| FactoryBot.create(:user_location, user: u) }
    end

    trait :unconfirmed do
      after(:build) { |u| u.confirmed_at = nil }
    end

    factory :stewie do
      email { "stewie@example.com" }
      full_name { "Stewie Griffin" }
      display_name { "Stewie" }
      password { "Victory is mine!" }
      password_confirmation { "Victory is mine!" }
      admin

      factory :stewie_with_profile do
        # This is repeated here due to with_profile trait not being found
        after(:build) { |u| FactoryBot.build(:user_profile, user: u) }
      end
    end

    factory :brian do
      email { "brian@example.com" }
      full_name { "Brian Griffin" }
      display_name { "Brian" }
      password { "BRI-D0G" }
      password_confirmation { "BRI-D0G" }
    end

    factory :meg do
      email { "meg@example.com" }
      full_name { "Meg Griffin" }
      display_name { "Meg" }
      password { "MegGriffin" }
      password_confirmation { "MegGriffin" }
    end

    factory :chris do
      email { "chris@example.com" }
      full_name { "Chris Griffin" }
      display_name { "Chris" }
      password { "ChrisGriffin" }
      password_confirmation { "ChrisGriffin" }
    end

    factory :user_with_location, traits: [:with_location]
  end
end
