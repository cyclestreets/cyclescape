class MapMessage < MessageComponent
  include Locatable
  validates :location, presence: true
end
