# frozen_string_literal: true



class PotentialMember < ApplicationRecord
  belongs_to :group

  validates :group, :email_hash, presence: true
  validate :ensure_email_is_uniq_per_group
  validates :email, format: { with: Devise.email_regexp, allow_nil: true, message: :email_format_invalid }
  attr_reader :email

  scope :email_eq, ->(email) { where(email_hash: Digest::SHA256.hexdigest(email)) }

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

# == Schema Information
#
# Table name: potential_members
#
#  id         :integer          not null, primary key
#  email_hash :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer
#
# Indexes
#
#  index_potential_members_on_email_hash_and_group_id  (email_hash,group_id) UNIQUE
#  index_potential_members_on_group_id                 (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
