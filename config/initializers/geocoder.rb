# frozen_string_literal: true

module Geocoder
  API_KEY = Rails.application.credentials.cyclestreets
  CS_BASE_URL    = "https://api.cyclestreets.net/v2/"
  GEO_URL        = "#{CS_BASE_URL}geocoder"
  COLLISIONS_URL = "#{CS_BASE_URL}collisions.locations"
  PHOTO_URL      = "#{CS_BASE_URL}photomap.locations"
  PHOTO_LOCATION_URL = "#{CS_BASE_URL}photomap.location"
  FEEDBACK_URL = "#{CS_BASE_URL}feedback.add"
end
