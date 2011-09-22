FactoryGirl.define do
  factory :stewie_at_quahogcc, :class => GroupMembership do
    group :quahogcc
    user :stewie
    role "committee"
  end
end
