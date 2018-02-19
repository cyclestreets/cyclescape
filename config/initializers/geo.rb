module Geo
  USER_LOCATIONS_BUFFER = 0.001
  POINT_ZOOM = 16
  MAP_SEARCH_ZOOM = 14
  # If you see this place, then there's a better choice of places to use.
  ISSUE_MAX_AREA = 0.1 # square degrees
end

RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  # By default, use the GEOS implementation for spatial columns.
  config.default = RGeo::Geos.factory_generator

  # But use a geographic implementation for point columns.
  config.register(RGeo::Geographic.spherical_factory(srid: 4326), geo_type: "point")
end
