module Locatable
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

    # define a variant of intersects that doesn't include entirely surrouding polygons
    def intersects_not_covered(loc)
      sanatize_multi_geoms(loc) do |l|
        intersects(l).where('NOT ST_CoveredBy(?, ST_Envelope(location))', [l])
      end
    end

    def rgeo_factory
      # Uses the store, a fancy way of doing
      # `RGeo::Geos.factory(srid: 4326)`
      store = RGeo::ActiveRecord::SpatialFactoryStore.instance
      srid = store.registry.values[0].srid
      store.default.call(srid: srid)
    end

    def order_by_size(order = "DESC")
      order("ST_Area(location) #{order}")
    end

    def select_area
      select('*, -ST_Area(location) AS area')
    end

    private

    def sanatize_multi_geoms(l)
      return none unless l.present?
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

  # Returns the size of the location. Returns 0 for anything other than polygons.
  def size
    if !location.try(:geometry_type)
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
    if json_str.blank?
      self.location = nil
      return
    end
    # Not clear why the factory is needed, should be taken care of by setting the srid on the factory_generator
    # but that doesn't work.
    factory = RGeo::Geos.factory(srid: 4326)
    feature = RGeo::GeoJSON.decode(json_str, geo_factory: factory, json_parser: :json)
    return unless feature
    geom = feature.try(:geometry)
    self.location = geom || factory.collection(feature.map(&:geometry))
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
