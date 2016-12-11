class PotentialMember < ActiveRecord::Base
  belongs_to :group

  validates :group, :email_hash, presence: true

  scope :email_eq, -> (email) { where(email_hash: Digest::SHA256.hexdigest(email)) }

  def email=(email)
    self.email_hash = Digest::SHA256.hexdigest(email)
  end
end
