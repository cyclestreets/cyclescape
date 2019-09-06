# frozen_string_literal: true

class GeoCoerce
  def self.call(geo)
    parsed =
      begin
        RGeo::GeoJSON.decode(geo, geo_factory: Constituency.rgeo_factory)
      rescue JSON::ParserError
        nil
      end
    parsed || geo
  end
end
