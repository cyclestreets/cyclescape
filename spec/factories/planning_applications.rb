# == Schema Information
#
# Table name: planning_applications
#
#  id                      :integer          not null, primary key
#  openlylocal_id          :integer          not null
#  openlylocal_url         :text
#  address                 :text
#  postcode                :string(255)
#  description             :text
#  council_name            :string(255)
#  openlylocal_council_url :string(255)
#  url                     :text
#  uid                     :string(255)      not null
#  issue_id                :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  location                :spatial({:srid=>
#

FactoryGirl.define do
  factory :planning_application do
    sequence(:openlylocal_id)
    sequence(:openlylocal_url) { |n| "http://example.com/planning/#{n}" }
    address "15 Foo Street, Placeville"
    postcode "SW1A 1AA"
    description "Add twelve additional storeys to the garden shed"
    council_name "Placeville County Council"
    openlylocal_council_url "http://example.com/councils/placeville"
    url "http://example.net/gov/planning_applications/0013-150-1553"
    uid "07/00026/FUL"
    location "POINT(-122 47)"

    trait :with_issue do
      association :issue
    end
  end
end
