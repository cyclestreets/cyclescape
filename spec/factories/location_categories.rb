# == Schema Information
#
# Table name: location_categories
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

FactoryGirl.define do
  factory :location_category do
    sequence(:name) { |n| "User location category #{n}" }
  end
end
