module ApplicationHelper
  def cancel_link(url = {action: :index})
    content_tag("li", class: "cancel") do
      link_to t("cancel"), url
    end
  end

  def basic_map(&block)
    @map = MapLayers::Map.new("map", {theme: "/openlayers/theme/default/style.css", projection: googleproj, displayProjection: projection}) do |map, page|
      page << map.add_layer(OpenLayers::Layer::OSM.new("OpenCycleMap", ["a", "b", "c"].map {|k| "http://#{k}.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png"}))
      page << map.add_layer(MapLayers::OSM_MAPNIK)
      page << map.add_control(OpenLayers::Control::LayerSwitcher.new)

      format = MapLayers::JsVar.new("format")
      page.assign(format, OpenLayers::Format::GeoJSON.new(internalProjection: googleproj, externalProjection: projection))

      format_plain = MapLayers::JsVar.new("format_plain")
      page.assign(format_plain, OpenLayers::Format::GeoJSON.new)

      yield(map, page) if block_given?
    end
  end

  def projection
    OpenLayers::Projection.new("EPSG:4326")
  end

  def googleproj
    OpenLayers::Projection.new("EPSG:900913")
  end
end
