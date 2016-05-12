module Geocoder
  cs_api_file = Rails.root.join('config', 'cyclestreets')
  if cs_api_file.exist?
    API_KEY = cs_api_file.read.strip
  else
    API_KEY = ''
  end
  URL = 'https://api.cyclestreets.net/v2/geocoder'
  COLLISIONS_URL = 'https://api.cyclestreets.net/v2/collisions.locations'
end
