FactoryGirl.define do
  factory :group_membership_request do
    factory :pending_gmr do
      group
      user
    end
  end
end