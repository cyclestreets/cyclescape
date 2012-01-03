# == Schema Information
#
# Table name: tags
#
#  id   :integer         not null, primary key
#  name :string(255)     not null
#

FactoryGirl.define do
  sequence(:tag, "a") {|n| "tag#{n}" } 

  factory :tag do
    name { FactoryGirl.generate(:tag) }
  end
end
