# == Schema Information
#
# Table name: user_locations
#
#  id          :integer         not null, primary key
#  user_id     :integer         not null
#  category_id :integer         not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  location    :spatial({:srid=
#

FactoryGirl.define do
  factory :user_location do
    location "POINT(2 2)"
    association :category, factory: :location_category
    association :user

    factory :user_location_with_json_loc do
      loc_json '{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.14,52.27]}}'
    end
  end
end
