# frozen_string_literal: true

class CyclestreetsPhotoMessage < MessageComponent
  include Photo
  include Locatable

  validates :location, :photo, presence: true

  def searchable_text
    caption
  end
end
