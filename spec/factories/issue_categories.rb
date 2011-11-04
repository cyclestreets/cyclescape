# == Schema Information
#
# Table name: issue_categories
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

FactoryGirl.define do
  factory :issue_category do
    sequence(:name) {|n| "Bike Parking #{n}" }
  end
end
