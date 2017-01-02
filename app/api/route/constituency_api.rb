module Route
  class ConstituencyApi < Base
    desc 'Returns Constituencies boundary and name as GeoJSON'

    params do
      requires(:geo,
               type: RGeo::Geos::CAPIPointImpl, desc: 'GeoJSON of the location, the surrouding constituency will be returned, e.g. {"type":"Point","coordinates":[0.11906,52.20792]}',
               coerce_with: lambda do |geo|
                 parsed = RGeo::GeoJSON.decode(geo, geo_factory: Constituency.rgeo_factory, json_parser: :json)
                 raise unless parsed
                 parsed
               end)
    end

    get :constituencies do
      const = Constituency.intersects(params[:geo]).first
      error! "No constituencies found for the given point" unless const

      feature = RGeo::GeoJSON::Feature.new(const.location, nil, name: const.name)
      RGeo::GeoJSON.encode(feature)
    end
  end
end
