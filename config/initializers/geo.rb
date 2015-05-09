module Geo
  USER_LOCATIONS_BUFFER = 0.001
  POINT_ZOOM = 16
  MAP_SEARCH_ZOOM = 14
  # If you see this place, then there's a better choice of places to use.
  NOWHERE_IN_PARTICULAR = RGeo::Geos.factory(has_z_coordinate: true).point(0.1275, 51.5032, 6)
  ISSUE_MAX_AREA = 0.1 # square degrees

  COLLISIONS_API_KEY = 'b7af2f6899b5d784'
  COLLISIONS_URL = 'https://api.cyclestreets.net/v2/collisions.locations'
end
