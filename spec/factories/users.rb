FactoryGirl.define do
  factory :user do
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
