FactoryGirl.define do
  factory :group_membership_request do
    factory :pending_gmr do
      group
      user
    end

    factory :meg_joining_quahogcc do
      association :user, factory: :meg
      association :group, factory: :quahogcc
    end
  end
end