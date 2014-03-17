# == Schema Information
#
# Table name: group_memberships
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  group_id   :integer         not null
#  role       :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  deleted_at :datetime
#

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
