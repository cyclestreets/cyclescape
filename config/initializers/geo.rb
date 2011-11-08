module Geo
  USER_LOCATIONS_BUFFER = 0.001
  # If you see this place, then there's a better choice of places to use.
  NOWHERE_IN_PARTICULAR = RGeo::Geos::Factory.create({has_z_coordinate: true}).point(-6.2248, 57.4658, 14)
end