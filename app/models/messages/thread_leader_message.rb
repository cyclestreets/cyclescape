class ThreadLeaderMessage < MessageComponent
  belongs_to :unleading, class_name: ThreadLeaderMessage

  scope :active, -> { where(active: true, unleading: nil) }

  validate :user_ownes_unleading

  before_create :deactivae_unleading

  class << self
    def already_leading(user, thread)
      active.find_by(thread: thread, created_by: user)
    end
  end

  private

  def user_ownes_unleading
    return if !unleading_id || unleading.created_by_id == created_by_id
    errors.add(:base, "Something went wrong")
  end

  def deactivae_unleading
    unleading.update(active: false) if unleading
  end
end
