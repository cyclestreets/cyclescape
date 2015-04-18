class StreetViewMessage < MessageComponent
  attr_accessible :caption, :heading, :pitch

  validates :caption, :heading, :pitch, :location, presence: true

  def set_location(location_string)
    x, y = location_string.split(',').map &:to_i
    self.location = RGeo::Geos.factory(srid: 4326).point(x, y)
  end

end
