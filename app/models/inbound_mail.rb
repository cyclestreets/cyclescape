class InboundMail < ActiveRecord::Base
  def self.new_from_message(mail)
    new recipient: mail.to.first, message: mail.to_s
  end
end
