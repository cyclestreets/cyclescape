module Route
  class WardApi < Base
    desc 'Returns ward boundary and name as GeoJSON'

    params do
      requires(:geo,
               type: RGeo::Geos::CAPIPointImpl, desc: 'GeoJSON of the location, the surrouding ward will be returned, e.g. {"type":"Point","coordinates":[0.11906,52.20792]}',
               coerce_with: lambda do |geo|
                 parsed = RGeo::GeoJSON.decode(geo, geo_factory: Ward.rgeo_factory, json_parser: :json)
                 raise unless parsed
                 parsed
               end)
    end

    get :wards do
      const = Ward.intersects(params[:geo]).first
      error! "No wards found for the given point" unless const

      feature = RGeo::GeoJSON::Feature.new(const.location, nil, name: const.name)
      RGeo::GeoJSON.encode(feature)
    end
  end
end
