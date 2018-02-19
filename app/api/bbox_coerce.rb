# frozen_string_literal: true

class BboxCoerce
  def self.call(bbox_string)
    return unless bbox_string
    factory = Issue.rgeo_factory
    minlon, minlat, maxlon, maxlat = bbox_string.split(',').collect(&:to_f)
    bbox = RGeo::Cartesian::BoundingBox.new(factory)
    bbox.add(factory.point(minlon, minlat)).add(factory.point(maxlon, maxlat))
  end
end
