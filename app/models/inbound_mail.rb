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

class InboundMail < ActiveRecord::Base
  extend Memoist

  validates :recipient, :raw_message, presence: true

  def self.new_from_message(mail)
    new recipient: mail.to.first, raw_message: mail.to_s
  end

  def message
    Mail.new(raw_message)
  end
  memoize :message
end
