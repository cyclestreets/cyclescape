FactoryGirl.define do
  factory :issue do
    title "There's something wrong"
    description "Whose leg do you have to hump to get a dry martini around here?"
    association :created_by, factory: :user
  end
end