# frozen_string_literal: true

module Geocoder
  cs_api_file = Rails.root.join("config", "cyclestreets")
  API_KEY = if cs_api_file.exist?
              cs_api_file.read.strip.freeze
            else
              ""
            end
  CS_BASE_URL    = "https://api.cyclestreets.net/v2/"
  GEO_URL        = "#{CS_BASE_URL}geocoder"
  COLLISIONS_URL = "#{CS_BASE_URL}collisions.locations"
  PHOTO_URL      = "#{CS_BASE_URL}photomap.locations"
  PHOTO_LOCATION_URL = "#{CS_BASE_URL}photomap.location"
  FEEDBACK_URL = "#{CS_BASE_URL}feedback.add"
end
