module MapsHelper
  def basic_map(&block)
    @map = core_map("map") do |map, page|
      page << map.add_layer(MapLayers::OPENCYCLEMAP)
      page << map.add_layer(MapLayers::OSM_MAPNIK)
      page << map.add_layer(MapLayers::OS_STREETVIEW)

      page << map.add_controls([OpenLayers::Control::PZ.new,
                                OpenLayers::Control::Navigation.new,
                                OpenLayers::Control::LayerSwitcher.new])

      add_formats(page)

      page << 'MapDisplay.init(map)'
      page << 'MapDisplay.setSavedLayers()'

      yield(map, page) if block_given?
    end
  end

  # If you need to show the same tiny_display_map twice on the one page, give different prefixes
  def tiny_display_map(object, geometry_url, prefix, &block)
    dom_id = dom_id(object, prefix)
    @map = core_map(dom_id) do |map, page|
      page << map.add_layer(MapLayers::OPENCYCLEMAP)

      add_formats(page)

      if object.location.geometry_type == RGeo::Feature::Point
        z = object.location.z || Geo::POINT_ZOOM
        page << map.setCenter(OpenLayers::LonLat.new(object.location.x,object.location.y).transform(projection, map.getProjectionObject()),z);
      else
        bbox = RGeo::Cartesian::BoundingBox.new(object.location.factory)
        bbox.add(object.location)
        page << map.zoomToExtent(OpenLayers::Bounds.new(bbox.min_x, bbox.min_y, bbox.max_x, bbox.max_y).transform(projection, map.getProjectionObject()))
      end

      locationlayer = MapLayers::JsVar.new('locationlayer')
      protocol = OpenLayers::Protocol::HTTP.new( url: geometry_url, format: :format_plain )
      page.assign(locationlayer, OpenLayers::Layer::Vector.new( "Location",
                                                                protocol: protocol,
                                                                projection: projection,
                                                                styleMap: 'MapStyle.displayStyle()'.to_sym,
                                                                strategies: [OpenLayers::Strategy::Fixed.new()]))
      page << map.addLayer(locationlayer)

      yield(map, page, dom_id) if block_given?
    end
  end

  def display_bbox_map(start_location, geometry_bbox_url, &block)
    map = basic_map do |map, page|
      if start_location.geometry_type == RGeo::Feature::Point
        z = start_location.z || Geo::POINT_ZOOM
        page << map.setCenter(OpenLayers::LonLat.new(start_location.x, start_location.y).transform(projection, map.getProjectionObject()),z);
      else
        bbox = RGeo::Cartesian::BoundingBox.new(start_location.factory)
        bbox.add(start_location)
        page << map.zoomToExtent(OpenLayers::Bounds.new(bbox.min_x, bbox.min_y, bbox.max_x, bbox.max_y).transform(projection, map.getProjectionObject()))
      end
      vectorlayer = MapLayers::JsVar.new("vectorlayer")
      protocol = OpenLayers::Protocol::HTTP.new( url: geometry_bbox_url, format: :format_plain )
      page.assign(vectorlayer, OpenLayers::Layer::Vector.new("Issues",
                                                             protocol: protocol,
                                                             projection: projection,
                                                             styleMap: 'MapStyle.displayStyle()'.to_sym,
                                                             strategies: [OpenLayers::Strategy::BBOX.new()]))
      page << map.add_layer(vectorlayer)
      page << 'MapPopup.init(map, vectorlayer)'
      yield(map, page) if block_given?
    end
  end

  def projection
    OpenLayers::Projection.new("EPSG:4326")
  end

  def googleproj
    OpenLayers::Projection.new("EPSG:900913")
  end

  protected

  def core_map(dom_id, &block)
    map = MapLayers::Map.new(dom_id, {theme: "/openlayers/theme/default/style.css",
                                        projection: googleproj,
                                        displayProjection: projection,
                                        controls: []
                                       }) do |map, page|
      yield(map, page) if block_given?
    end
  end

  def add_formats(page)
    format = MapLayers::JsVar.new("format")
    page.assign(format, OpenLayers::Format::GeoJSON.new(internalProjection: googleproj, externalProjection: projection))

    format_plain = MapLayers::JsVar.new("format_plain")
    page.assign(format_plain, OpenLayers::Format::GeoJSON.new)
  end
end