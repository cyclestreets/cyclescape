FactoryGirl.define do
  factory :group_membership do
    group
    user
    role 'member'

    trait :committee do
      role 'committee'
    end

    # Site admin but not committee member
    factory :stewie_at_quahogcc do
      association :group, factory: :quahogcc
      association :user, factory: :stewie
    end

    # Committee member
    factory :brian_at_quahogcc do
      association :group, factory: :quahogcc
      user { FactoryGirl.create(:brian) }  # Needs to already exist otherwise invitation will be sent
      committee
    end

    # Group member, nothing more
    factory :chris_at_quahogcc do
      association :group, factory: :quahogcc
      user { FactoryGirl.create(:chris) }
    end
  end
end
