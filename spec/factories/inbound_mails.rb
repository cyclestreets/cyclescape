FactoryGirl.define do
  factory :inbound_mail do
    ignore do
      to false
    end

    recipient { to || "traumatic@strangeperil.co.uk" }
    raw_message { File.read(raw_email_path("basic")) }

    after_build do |mail, proxy|
      if proxy.to
        # Get a Mail object, rewrite the recipient and save
        mesg = mail.message
        mesg.to = proxy.to
        mail.raw_message = mesg.to_s
      end
    end
  end
end
