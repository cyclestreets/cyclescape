FactoryGirl.define do
  factory :photo_message do
    association :created_by, factory: :user
    association :message, factory: :message
    sequence(:caption) {|n| "Imaginative photo caption #{n}" }
    photo { Pathname.new(test_photo_path) }

    after_build do |o|
      o.thread = o.message.thread
      o.message.update_attributes(component: o)
    end
  end
end
