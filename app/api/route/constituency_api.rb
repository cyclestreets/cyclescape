module Route
  class ConstituencyApi < Base
    desc 'Returns Constituencies boundary and name as GeoJSON'

    params do
      requires :geo, type: String, desc: 'GeoJSON of the location, the surrouding constituency will be returned'
    end

    get :constituencies do
      geom = RGeo::GeoJSON.decode(params[:geo], geo_factory: Constituency.rgeo_factory, json_parser: :json).geometry
      const = Constituency.intersects(geom).first
      return unless const

      feature = RGeo::GeoJSON::Feature.new(const.location, nil, name: const.name)
      RGeo::GeoJSON.encode(feature)
    end
  end
end
