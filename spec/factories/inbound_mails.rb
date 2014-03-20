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

    recipient { to || 'cyclescape@example.com' }
    raw_message { File.read(raw_email_path('basic')) }

    after(:build) do |mail, proxy|
      if proxy.to
        # Get a Mail object, rewrite the recipient and save
        mesg = mail.message
        mesg.to = proxy.to
        mail.raw_message = mesg.to_s
      end
    end

    trait :multipart_text_only do
      raw_message { File.read(raw_email_path('qp_text_only_multipart'), encoding: 'UTF-8') }
    end

    trait :multipart_iso_8859_1 do
      raw_message { File.read(raw_email_path('qp_text_only_multipart_iso-8859-1')) }
    end

    trait :with_attached_image do
      raw_message { File.read(raw_email_path('attached_image')) }
    end

    trait :with_attached_file do
      raw_message { File.read(raw_email_path('attached_file')) }
    end

    trait :encoded_subject do
      raw_message { File.read(raw_email_path('encoded_subject')) }
    end
  end
end
