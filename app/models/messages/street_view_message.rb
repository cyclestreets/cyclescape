class StreetViewMessage < MessageComponent
  validates :caption, :heading, :pitch, :location, presence: true

  def set_location(location_string)
    y, x = location_string.gsub(/[()]/, "").split(',').map &:to_f
    self.location = RGeo::Geos.factory(srid: 4326).point(x, y)
  end

end
