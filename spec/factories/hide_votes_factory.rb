# frozen_string_literal: true

FactoryBot.define do
  factory :hide_vote do
    user
    planning_application
  end
end
