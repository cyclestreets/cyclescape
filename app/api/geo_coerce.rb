# frozen_string_literal: true

class GeoCoerce
  def self.call(geo)
    parsed = RGeo::GeoJSON.decode(geo, geo_factory: Constituency.rgeo_factory)
    parsed || geo
  end
end
