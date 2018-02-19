# frozen_string_literal: true

class MapMessage < MessageComponent
  include Locatable
  validates :location, presence: true
end
