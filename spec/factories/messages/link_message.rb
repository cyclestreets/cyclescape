FactoryGirl.define do
  factory :link_message do
    association :created_by, factory: :user
    association :message, factory: :message
    url "http://en.wikipedia.org/wiki/Family_Guy"
    title "Family Guy - Wikipedia, the free encyclopedia"
    description "Family Guy is an American animated television series created by Seth MacFarlane."

    after_build do |o|
      o.thread = o.message.thread
      o.message.update_attributes(component: o)
    end
  end
end
