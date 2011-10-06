class GroupProfile < ActiveRecord::Base
  belongs_to :group

  self.rgeo_factory_generator = RGeo::Geos.factory_generator

  def loc_json=(json_str)
    # Not clear why the factory is needed, should be taken care of by setting the srid on the factory_generator
    # but that doesn't work.
    factory = RGeo::Geos::Factory.new(srid: 4326)
    feature = RGeo::GeoJSON.decode(json_str, :geo_factory => factory, :json_parser => :json)
    self.location = feature.geometry if feature
  end

  def loc_json
    if self.location
      RGeo::GeoJSON.encode(self.location).to_json
    else
      ""
    end
  end
end
