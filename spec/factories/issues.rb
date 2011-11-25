# == Schema Information
#
# Table name: issues
#
#  id            :integer         not null, primary key
#  created_by_id :integer         not null
#  title         :string(255)     not null
#  description   :text            not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  deleted_at    :datetime
#  category_id   :integer
#  location      :spatial({:srid=
#

FactoryGirl.define do
  factory :issue do
    title "There's something wrong"
    description "Whose leg do you have to hump to get a dry martini around here?"
    location "POINT(-122 47)"
    association :created_by, factory: :user
    association :category, factory: :issue_category

    factory :issue_with_json_loc do
      loc_json '{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.14,52.27]}}'
    end

    trait :with_tags do
      tags { FactoryGirl.build_list(:tag, 2) }
    end
  end
end
