# frozen_string_literal: true

module MapsHelper
  def location_to_geojson(central_location)
    feature = if central_location.geometry_type == RGeo::Feature::Point
                z = central_location.z || Geo::POINT_ZOOM
                { latLon: [central_location.y, central_location.x], zoom: z }
              else
                bbox = RGeo::Cartesian::BoundingBox.new(central_location.factory)
                bbox.add central_location
                { fitBounds: [[bbox.min_y, bbox.min_x], [bbox.max_y, bbox.max_x]] }
              end
    feature.to_json
  end

  def item_to_geojson(decorated_item)
    return nil unless decorated_item.try(:location)

    collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(
      decorated_item.locations_array.map do |location|
        RGeo::GeoJSON::Feature.new(
          location, nil,
          thumbnail: decorated_item.try(:medium_icon_path),
          anchor: decorated_item.try(:medium_icon_anchor)
        )
      end
    )
    RGeo::GeoJSON.encode(collection)
  end
end
