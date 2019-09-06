# frozen_string_literal: true

FactoryBot.define do
  factory :user_location do
    location { "POINT(2 2)" }
    association :user

    factory :user_location_with_json_loc do
      loc_json { '{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.14,52.27]}}' }
    end
  end
end
