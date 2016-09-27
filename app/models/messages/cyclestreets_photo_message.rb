class CyclestreetsPhotoMessage < MessageComponent
  include Photo
  include Locatable

  validates :location, :photo, presence: true

  def searchable_text
    [caption, cyclestreet_caption, cyclestreet_category].join(' ')
  end
end
