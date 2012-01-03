/**
 * Saving OpenLayers map information via cookies
 *
 * Based on code from OpenCycleMap / OpenStreetMap
 * Licensed under the  GPLv2 license:
 * http://www.gnu.org/licenses/gpl-2.0.html
 *
 */
MapDisplay = {
  map: null,

  init: function (m) {
    this.map = m;
    map.events.register("moveend", map, this.updateLocation);
    map.events.register("changelayer", map, this.updateLocation);
  },

  updateLocation: function () {
    if (map.getCenter()) {
      var lonlat = map.getCenter().clone().transform(map.getProjectionObject(), new OpenLayers.Projection("EPSG:4326"));
      var zoom = map.getZoom();
      var layers = MapDisplay.getMapLayers();
      var loc_string = lonlat.lon + "|" + lonlat.lat + "|" + zoom + "|" + layers;
      $.cookie('_cyclescape_location', loc_string, { path: "/", expires: 30 });
    }
  },

  getMapLayers: function () {
    var layerConfig = "";

    for (var layers = map.getLayersBy("isBaseLayer", true), i = 0; i < layers.length; i++) {
        layerConfig += layers[i] == map.baseLayer ? "B" : "0";
    }

    for (var layers = map.getLayersBy("isBaseLayer", false), i = 0; i < layers.length; i++) {
        layerConfig += layers[i].getVisibility() ? "T" : "F";
    }

    return layerConfig;
  },

  setSavedLayers: function() {
    var savedLayers = MapDisplay.getSavedLayers();
    if (savedLayers) {
      MapDisplay.setMapLayers(savedLayers);
    }
  },

  setMapLayers: function(layerConfig) {
    var l = 0;

    for (var layers = map.getLayersBy("isBaseLayer", true), i = 0; i < layers.length; i++) {
      var c = layerConfig.charAt(l++);

      if (c == "B") {
        map.setBaseLayer(layers[i]);
      }
    }

    while (layerConfig.charAt(l) == "B" || layerConfig.charAt(l) == "0") {
      l++;
    }

    for (var layers = map.getLayersBy("isBaseLayer", false), i = 0; i < layers.length; i++) {
      var c = layerConfig.charAt(l++);

      if (c == "T") {
        layers[i].setVisibility(true);
      } else if(c == "F") {
        layers[i].setVisibility(false);
      }
    }
  },

  getSavedLayers: function () {
    var cookietext = $.cookie('_cyclescape_location');
    var layers;
    if (cookietext) {
      var cb = cookietext.split('|');
      //centre = lonLatToMercator( new OpenLayers.LonLat(cb[0], cb[1]));
      //zoom = cb[2];
      layers = cb[3];
    }
    return layers;
  }
}
