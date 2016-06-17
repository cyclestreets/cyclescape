module MapLayers
  OPENCYCLEMAP = OpenLayers::Layer::OSM.new(
    'OpenCycleMap',
    %w(a b c).map { |k| "http://#{k}.tile.cyclestreets.net/opencyclemap/${z}/${x}/${y}@2x.png" },
    opacity: 0.8, tileOptions: { crossOriginKeyword: :null }
  )
  OS_STREETVIEW = OpenLayers::Layer::OSM.new(
    'OS StreetView',
    %w(a b c).map { |k| "http://#{k}.tile.cyclestreets.net/osopendata/${z}/${x}/${y}.png" },
    opacity: 0.8, tileOptions: { crossOriginKeyword: :null }
  )
  MAPNIK = OpenLayers::Layer::OSM.new(
    'OpenStreetMap',
    %w(a b c).map { |k| "http://#{k}.tile.cyclestreets.net/mapnik/${z}/${x}/${y}.png" },
    opacity: 0.8, tileOptions: { crossOriginKeyword: :null }
  )
end
