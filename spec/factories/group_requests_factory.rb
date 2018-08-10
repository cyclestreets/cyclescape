FactoryBot.define do
  factory :group_request do
    sequence(:name) { |n| "Req Campaign Group #{n}" }
    sequence(:short_name) { |n| "reqcc#{n}" }
    sequence(:website) { |n| "http://www.cc#{n}.com" }
    sequence(:email) { |n| "admin@req_cc#{n}.com" }
    user
  end
end
