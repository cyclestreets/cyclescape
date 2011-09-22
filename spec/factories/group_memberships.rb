FactoryGirl.define do
  factory :group_membership do
    group
    user
    role "member"

    trait :committee do
      role "committee"
    end
  end

  factory :stewie_at_quahogcc, :class => GroupMembership do
    group :quahogcc
    user :stewie
    role "committee"
  end
end
