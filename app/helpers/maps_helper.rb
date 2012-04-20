module MapsHelper
  def basic_map(&block)
    @map = core_map("map") do |map, page|
      page << map.add_layer(MapLayers::OPENCYCLEMAP)
      page << map.add_layer(MapLayers::OSM_MAPNIK)
      page << map.add_layer(MapLayers::OS_STREETVIEW)

      page << map.add_controls([OpenLayers::Control::PZ.new,
                                OpenLayers::Control::Navigation.new,
                                OpenLayers::Control::LayerSwitcher.new({roundedCornerColor: "#575757"})])

      add_formats(page)

      page << 'MapDisplay.init(map)'
      page << 'MapDisplay.setSavedLayers()'

      yield(map, page) if block_given?
    end
  end

  def display_map(object, geometry_url, &block)
    @map = basic_map() do |map, page|
      centre_map(object.location, map, page)
      add_location_layer("Location", geometry_url, OpenLayers::Strategy::Fixed.new(), map, page)

      yield(map, page) if block_given?
    end
  end

  # If you need to show the same tiny_display_map twice on the one page, give different prefixes
  def tiny_display_map(object, geometry_url, prefix, &block)
    dom_id = dom_id(object, prefix)
    @map = core_map(dom_id) do |map, page|
      page << map.add_layer(MapLayers::OPENCYCLEMAP)
      add_formats(page)
      centre_map(object.location, map, page)
      add_location_layer("Location", geometry_url, OpenLayers::Strategy::Fixed.new(), map, page)

      yield(map, page, dom_id) if block_given?
    end
  end

  def display_bbox_map(start_location, geometry_bbox_url, &block)
    map = basic_map do |map, page|
      centre_map(start_location, map, page)
      add_location_layer("Issues", geometry_bbox_url, OpenLayers::Strategy::BBOX.new(resFactor: 3, ratio: 1.5), map, page)
      page << 'MapPopup.init(map, locationlayer)'

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

  def centre_map(location, map, page)
    if location.geometry_type == RGeo::Feature::Point
      z = location.z || Geo::POINT_ZOOM
      page << map.setCenter(OpenLayers::LonLat.new(location.x,location.y).transform(projection, map.getProjectionObject()),z);
    else
      bbox = RGeo::Cartesian::BoundingBox.new(location.factory)
      bbox.add(location)
      page << map.zoomToExtent(OpenLayers::Bounds.new(bbox.min_x, bbox.min_y, bbox.max_x, bbox.max_y).transform(projection, map.getProjectionObject()))
    end
  end

  def add_location_layer(name, url, strategy, map, page)
    locationlayer = MapLayers::JsVar.new('locationlayer')
    protocol = OpenLayers::Protocol::HTTP.new( url: url, format: :format_plain )
    page.assign(locationlayer, OpenLayers::Layer::Vector.new( name,
                                                                protocol: protocol,
                                                                projection: projection,
                                                                styleMap: 'MapStyle.displayStyle()'.to_sym,
                                                                rendererOptions: {yOrdering: true, zIndexing: true},
                                                                strategies: [strategy]))
    page << map.add_layer(locationlayer)
  end
end