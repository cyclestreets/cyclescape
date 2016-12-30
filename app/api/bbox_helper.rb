module BboxHelper
  def bbox_from_string(string, factory)
    return unless string
    minlon, minlat, maxlon, maxlat = string.split(',').collect(&:to_f)
    bbox = RGeo::Cartesian::BoundingBox.new(factory)
    bbox.add(factory.point(minlon, minlat)).add(factory.point(maxlon, maxlat))
  end
end
