module MapLayers
  OPENCYCLEMAP = OpenLayers::Layer::OSM.new("OpenCycleMap", ["a", "b", "c"].map {|k| "http://#{k}.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png"})
end