# frozen_string_literal: true

module Geocoder
  API_KEY = ENV["CYCLESTREETS"]
  CS_BASE_URL    = "https://api.cyclestreets.net/v2/"
  GEO_URL        = "#{CS_BASE_URL}geocoder"
  COLLISIONS_URL = "#{CS_BASE_URL}collisions.locations"
  PHOTO_URL      = "#{CS_BASE_URL}photomap.locations"
  PHOTO_LOCATION_URL = "#{CS_BASE_URL}photomap.location"
end
