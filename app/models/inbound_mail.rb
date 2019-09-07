# frozen_string_literal: true


class InboundMail < ApplicationRecord
  validates :recipient, :raw_message, presence: true
  has_many :messages

  def self.new_from_message(mail)
    recipient = mail.to.try(:first) || mail.cc.try(:first) || mail.bcc.try(:first)
    new recipient: recipient, raw_message: mail.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
  end

  def message
    @message ||= Mail.new(raw_message)
  end
end

# == Schema Information
#
# Table name: inbound_mails
#
#  id            :integer          not null, primary key
#  process_error :boolean          default(FALSE), not null
#  processed_at  :datetime
#  raw_message   :text             not null
#  recipient     :string(255)      not null
#  created_at    :datetime         not null
#
