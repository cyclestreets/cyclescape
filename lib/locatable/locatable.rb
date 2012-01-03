module Locatable
  def self.included(base)
    base.rgeo_factory_generator = RGeo::Geos.factory_generator
    base.extend(ClassMethods)
  end

  module ClassMethods
    # define an intersects method for arel queries
    # Note - pass in the location as an array, otherwise .each is called on
    # multipolygons and it serializes to multiple geometries.
    def intersects(l)
      where("st_intersects(location, ?)", [l])
    end

    # This could be improved by actually using the factory from the location column, rather
    # than creating a new one and hardcoding the srid.
    # However, there's a bug in Rgeo::ActiveRecord 0.4.0 that prevents rgeo_factory_for_column from working
    def rgeo_factory
      return RGeo::Geos::Factory.new(srid: 4326)
    end
  end

  # Define an approximate centre of the issue, for convenience.
  # Note that the line or polygon might be nowhere near this centre
  def centre
    case self.location.geometry_type
    when RGeo::Feature::Point
      return self.location
    else
      return self.location.envelope.centroid
    end
  end

  def loc_json=(json_str)
    # Not clear why the factory is needed, should be taken care of by setting the srid on the factory_generator
    # but that doesn't work.
    factory = RGeo::Geos::Factory.new(srid: 4326)
    feature = RGeo::GeoJSON.decode(json_str, :geo_factory => factory, :json_parser => :json)
    self.location = feature.geometry if feature
  end

  def loc_json
    if self.location
      RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(self.location)).to_json
    else
      ""
    end
  end
end