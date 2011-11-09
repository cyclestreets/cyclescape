FactoryGirl.define do
  factory :library_item, class: "Library::Item" do
    association :created_by, factory: :user
  end
end
