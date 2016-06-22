module Geocoder
  cs_api_file = Rails.root.join('config', 'cyclestreets')
  API_KEY = if cs_api_file.exist?
              cs_api_file.read.strip
            else
              ''
            end
  URL = 'https://api.cyclestreets.net/v2/geocoder'
end
