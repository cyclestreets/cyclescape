module MapLayers
  OPENCYCLEMAP = OpenLayers::Layer::OSM.new("OpenCycleMap", ["a", "b", "c"].map {|k| "http://#{k}.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png"},
                                            opacity: 0.8, tileOptions: { crossOriginKeyword: :null })
  OS_STREETVIEW = OpenLayers::Layer::OSM.new("OS StreetView", ["a", "b", "c"].map {|k| "http://#{k}.os.openstreetmap.org/sv/${z}/${x}/${y}.png"},
                                             opacity: 0.8, tileOptions: { crossOriginKeyword: :null })
end
