FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user#{n}@example.com" }
    sequence(:full_name) {|n| "User #{n}" }
    sequence(:password) {|n| "password#{n}" }
    sequence(:password_confirmation) {|n| "password#{n}" }
    after_build {|u| u.skip_confirmation! }

    factory :stewie do
      email "stewie@example.com"
      full_name "Stewie Griffin"
      display_name "Stewie"
      password "Victory is mine!"
      password_confirmation "Victory is mine!"

      factory :admin do
        role "admin"
      end
    end
  end
end
