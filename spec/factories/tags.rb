# == Schema Information
#
# Table name: tags
#
#  id   :integer         not null, primary key
#  name :string(255)     not null
#  icon :string(255)
#

FactoryGirl.define do
  sequence(:tag, "a") {|n| "tag#{n}" }

  factory :tag do
    name { FactoryGirl.generate(:tag) }

    factory :tag_with_icon do
      sequence(:icon) { |n| "icon-#{n}" }
    end
  end
end
