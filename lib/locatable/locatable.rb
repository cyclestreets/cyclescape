# frozen_string_literal: true

module Locatable
  extend ActiveSupport::Concern
  EMPTY_JSON = '{"type":"FeatureCollection","features":[]}'

  included do
    before_save :make_location_valid
  end

  def make_location_valid
    self.location = location.make_valid if location.respond_to?(:make_valid)
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def locations_array
    if location.geometry_type == RGeo::Feature::GeometryCollection
      location
    else
      Array.wrap(location)
    end
  end

  module ClassMethods
    # define an intersects method for arel queries
    # Note - pass in the location as an array, otherwise .each is called on
    # multipolygons and it serializes to multiple geometries.
    def intersects(loc)
      sanatize_multi_geoms(loc) do |l|
        where('ST_Intersects(ST_CollectionExtract(ST_MakeValid(ST_CollectionExtract(location, 3)), 3), ?) OR
               ST_Intersects(ST_CollectionExtract(location, 2), ?) OR
               ST_Intersects(ST_CollectionExtract(location, 1), ?)', [l], [l], [l])
      end
    end

    def with_center_inside(loc)
      sanatize_multi_geoms(loc) do |l|
        where(
          "ST_DWithin(
            ST_Centroid(location),
            ?,
            sqrt(ST_Area(?))/10
          )", [l], [l]
        )
      end
    end

    def rgeo_factory
      RGeo::ActiveRecord::SpatialFactoryStore.instance.default
    end

    def order_by_size(order = "DESC")
      order(Arel.sql("ST_Area(location) #{order}"))
    end

    def select_area
      select("*, -ST_Area(location) AS area")
    end

    private

    def sanatize_multi_geoms(l)
      return none if l.blank?

      l = l.envelope if l.geometry_type == RGeo::Feature::GeometryCollection
      yield l
    end
  end

  # Define an approximate centre of the issue, for convenience.
  # Note that the line or polygon might be nowhere near this centre
  def centre
    if location.geometry_type == RGeo::Feature::Point
      location
    else
      envelope = location.envelope
      if envelope.geometry_type == RGeo::Feature::Point
        envelope
      else
        envelope.centroid
      end
    end
  end

  # Returns the size of the location. Returns 0 for anything other than polygons and feature collections.
  def size
    SizableLocation.new(location).size
  end

  # Returns the ratio of the location vs the supplied geometry. Useful for seeing if the feature is larger
  # than a bounding box, for example.
  def size_ratio(geom)
    geom_size = SizableLocation.new(geom).size
    if geom_size.positive?
      size.to_f / geom_size
    else
      0.0
    end
  end

  class SizableLocation
    def initialize(loc_feature)
      @loc_feature = loc_feature
    end

    def size
      return 0.0 unless @loc_feature.try(:geometry_type)

      case @loc_feature.geometry_type
      when RGeo::Feature::Polygon
        @loc_feature.area.to_f
      when RGeo::Feature::GeometryCollection
        SizableLocation.new(@loc_feature.envelope).size
      else
        0.0
      end
    rescue RGeo::Error::RGeoError
      0.0
    end
  end

  def loc_json=(json_str)
    if json_str.blank? || json_str == EMPTY_JSON
      self.location = nil
      return
    end
    # Not clear why the factory is needed, should be taken care of by setting the srid on the factory_generator
    # but that doesn't work.
    factory = RGeo::Geos.factory(srid: 4326)
    feature =
      begin
        RGeo::GeoJSON.decode(json_str, geo_factory: factory)
      rescue JSON::ParserError, MultiJson::ParseError
        nil
      end
    return unless feature

    geom = feature.try(:geometry)
    self.location = geom || factory.collection(feature.map(&:geometry))
  end

  def loc_json
    if location
      RGeo::GeoJSON.encode(loc_feature).to_json
    else
      ""
    end
  end

  def loc_feature(properties = nil)
    if properties
      RGeo::GeoJSON::Feature.new(location, id, properties)
    else
      RGeo::GeoJSON::Feature.new(location)
    end
  end
end
