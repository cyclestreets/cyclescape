# frozen_string_literal: true

FactoryBot.define do
  factory :link_message do
    association :created_by, factory: :user
    association :message, factory: :message, strategy: :build
    url { "http://en.wikipedia.org/wiki/Family_Guy" }
    title { "Family Guy - Wikipedia, the free encyclopedia" }
    description { "Family Guy is an American animated television series created by Seth MacFarlane." }

    after(:build) do |o|
      o.thread = o.message.thread
      o.message.link_messages = [o]
    end
  end
end
