# frozen_string_literal: true

module Geocoder
  cs_api_file = Rails.root.join('config', 'cyclestreets')
  API_KEY = if cs_api_file.exist?
              cs_api_file.read.strip.freeze
            else
              ''.freeze
            end
  CS_BASE_URL    = 'https://api.cyclestreets.net/v2/'.freeze
  GEO_URL        = "#{CS_BASE_URL}geocoder".freeze
  COLLISIONS_URL = "#{CS_BASE_URL}collisions.locations".freeze
  PHOTO_URL      = "#{CS_BASE_URL}photomap.locations".freeze
end
