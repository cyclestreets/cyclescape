# == Schema Information
#
# Table name: library_items
#
#  id             :integer         not null, primary key
#  component_id   :integer
#  component_type :string(255)
#  created_by_id  :integer         not null
#  created_at     :datetime        not null
#  updated_at     :datetime
#  deleted_at     :datetime
#  location       :spatial({:srid=
#

FactoryBot.define do
  factory :library_item, class: 'Library::Item' do
    association :created_by, factory: :user
  end
end
