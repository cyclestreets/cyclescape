class DeadlineMessage < MessageComponent
  validates :deadline, presence: true
  validates :title, presence: true
end
