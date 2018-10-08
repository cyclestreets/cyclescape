# frozen_string_literal: true

class PotentialMember < ActiveRecord::Base
  belongs_to :group

  validates :group, :email_hash, presence: true
  validate :ensure_email_is_uniq_per_group
  validates_format_of :email, with: Devise::email_regexp, allow_nil: true, message: :email_format_invalid
  attr_reader :email

  scope :email_eq, -> (email) { where(email_hash: Digest::SHA256.hexdigest(email)) }

  def email=(new_email)
    @email = Mail::Address.new(new_email).address
    self.email_hash = Digest::SHA256.hexdigest(email)
  end

  private

  def ensure_email_is_uniq_per_group
    if group && group.potential_members.map(&:email_hash).select { |v| v == email_hash }.size > 1
      errors.add :email, :email_exists_in_group
    end
  end
end
