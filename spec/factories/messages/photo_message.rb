FactoryGirl.define do
  factory :photo_message do
    association :created_by, factory: :user
    association :message, factory: :message
    sequence(:caption) {|n| "Imaginative photo caption #{n}" }
    photo { Pathname.new(File.join(%w(spec support images abstract-100-100.jpg))) }

    after_build do |o|
      o.thread = o.message.thread
    end
  end
end
