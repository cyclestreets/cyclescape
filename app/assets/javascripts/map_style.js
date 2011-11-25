MapStyle = {
  editStyle: function() {
    var styleRules = [new OpenLayers.Rule({
      symbolizer: {"Line" : {strokeWidth: 3}},
      elseFilter: true
      })];
    var styleMap = new OpenLayers.StyleMap();
    styleMap.styles["default"].addRules(styleRules);
    styleMap.styles["select"].addRules(styleRules);
    return styleMap;
  },

  displayStyle: function() {
    var styleRules = [new OpenLayers.Rule({
        symbolizer: { "Line" : { strokeWidth: 8,
                                strokeColor: '#00ff00',
                                strokeOpacity: 0.8 },
                      "Point" : { pointRadius: 14,
                                  strokeColor: '#004400',
                                  strokeOpacity: 0.9,
                                  strokeWidth: 2,
                                  fillOpacity: 0.3,
                                  fillColor: '#00ff00' },
                      "Polygon" : { strokeWidth: 2.5,
                                    strokeOpacity: 0.8,
                                    strokeColor: '#004400',
                                    fillColor: '#00ff00' }
                    },
        elseFilter: true
      })];
    var styleMap = new OpenLayers.StyleMap();
    styleMap.styles["default"].addRules(styleRules);
    styleMap.styles["select"].addRules(styleRules);
    return styleMap;
  }
}
