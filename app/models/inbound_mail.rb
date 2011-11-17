class InboundMail < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  def self.new_from_message(mail)
    new recipient: mail.recipients.first, raw_message: mail.to_s
  end

  def message
    Mail.parse(raw_message)
  end
  memoize :message
end
