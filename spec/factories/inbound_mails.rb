# == Schema Information
#
# Table name: inbound_mails
#
#  id            :integer         not null, primary key
#  recipient     :string(255)     not null
#  raw_message   :text            not null
#  created_at    :datetime        not null
#  processed_at  :datetime
#  process_error :boolean         default(FALSE), not null
#

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

    trait :multipart_text_only do
      raw_message { File.read(raw_email_path("qp_text_only_multipart")) }
    end
  end
end
