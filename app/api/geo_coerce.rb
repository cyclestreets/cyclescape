# frozen_string_literal: true

class GeoCoerce
  def self.call(geo)
    parsed = RGeo::GeoJSON.decode(geo, geo_factory: Constituency.rgeo_factory, json_parser: :json)
    parsed || geo
  end
end
