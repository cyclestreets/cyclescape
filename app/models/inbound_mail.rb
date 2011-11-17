class InboundMail < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  validates :recipient, :raw_message, presence: true

  def self.new_from_message(mail)
    new recipient: mail.to.first, raw_message: mail.to_s
  end

  def message
    Mail.new(raw_message)
  end
  memoize :message
end
