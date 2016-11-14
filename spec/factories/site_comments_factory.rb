FactoryGirl.define do
  factory :site_comment do
    body "Meg: Mom, I can't clean, I've got stuff to do. Lois:\nMeg, we all know you don't have stuff to do"
    context_url 'http://www.example.com/'

    trait :from_user do
      user
    end

    trait :with_name_and_email do
      name 'Lois'
      email 'lois@example.com'
    end

    factory :site_comment_from_user, traits: [:from_user]
    factory :site_comment_with_contact_details, traits: [:with_name_and_email]
  end
end
