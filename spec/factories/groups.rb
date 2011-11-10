# == Schema Information
#
# Table name: groups
#
#  id                     :integer         not null, primary key
#  name                   :string(255)     not null
#  short_name             :string(255)     not null
#  website                :string(255)
#  email                  :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  disabled_at            :datetime
#  default_thread_privacy :string(255)     default("public"), not null
#

FactoryGirl.define do
  factory :group do
    sequence(:name) {|n| "Campaign Group #{n}" }
    sequence(:short_name) {|n| "cc#{n}" }
    sequence(:website) {|n| "http://www.cc#{n}.com" }
    sequence(:email) {|n| "admin@cc#{n}.com" }

    trait :disabled do
      disabled_at { DateTime.now }
    end

    factory :quahogcc do
      name "Quahog Cycling Campaign"
      short_name "quahogcc"
      website "http://www.quahogcc.com"
      email "louis@quahogcc.com"
    end
  end
end
