FactoryGirl.define do
  factory :group_membership do
    group
    user
    role "member"

    trait :committee do
      role "committee"
    end

    # Site admin but not committee member
    factory :stewie_at_quahogcc do
      group :quahogcc
      user :stewie
    end

    # Committee member
    factory :brian_at_quahogcc do
      group :quahogcc
      user :brian
      committee
    end
  end
end
