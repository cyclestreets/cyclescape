FactoryGirl.define do
  factory :inbound_mail do
    recipient "traumatic@strangeperil.co.uk"
    raw_message { File.read(raw_email_path("basic")) }
  end
end
