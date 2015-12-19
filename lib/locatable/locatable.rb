module Locatable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # define an intersects method for arel queries
    # Note - pass in the location as an array, otherwise .each is called on
    # multipolygons and it serializes to multiple geometries.
    def intersects(l)
      where('st_intersects(location, ?)', [l])
    end

    # define a variant of intersects that doesn't include entirely surrouding polygons
    def intersects_not_covered(l)
      intersects(l).where('not st_coveredby(?, location)', [l])
    end

    # This could be improved by actually using the factory from the location column, rather
    # than creating a new one and hardcoding the srid.
    # However, there's a bug in Rgeo::ActiveRecord 0.4.0 that prevents rgeo_factory_for_column from working
    def rgeo_factory
      return RGeo::Geos.factory(srid: 4326)
    end

    def order_by_size
      order('ST_Area(location) DESC')
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

  # Returns the size of the location. Returns 0 for anything other than polygons.
  def size
    if location.nil?
      return 0.0
    else
      case location.geometry_type
      when RGeo::Feature::Polygon
        return location.area.to_f
      else
        return 0.0
      end
    end
  end

  # Returns the ratio of the location vs the supplied geometry. Useful for seeing if the feature is larger
  # than a bounding box, for example.
  def size_ratio(geom)
    if geom && geom.geometry_type == RGeo::Feature::Polygon && geom.area > 0
      return size.to_f / geom.area
    else
      return 0.0
    end
  end

  def loc_json=(json_str)
    # Not clear why the factory is needed, should be taken care of by setting the srid on the factory_generator
    # but that doesn't work.
    factory = RGeo::Geos.factory(srid: 4326)
    feature = RGeo::GeoJSON.decode(json_str, geo_factory: factory, json_parser: :json)
    self.location = feature.geometry if feature
  end

  def loc_json
    if location
      RGeo::GeoJSON.encode(loc_feature).to_json
    else
      ''
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
