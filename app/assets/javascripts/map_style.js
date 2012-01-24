MapStyle = {
  displayRules: [new OpenLayers.Rule({
      symbolizer: {"Line" : { strokeWidth: 8,
                              strokeColor: '#333333',
                              strokeOpacity: 0.9 },
                    "Point" : { graphicWidth: 32,
                                graphicOpacity: 1.0,
                                graphicYOffset: -32,
                                externalGraphic: '${thumbnail}' },
                    "Polygon" : { strokeWidth: 2.5,
                                  strokeOpacity: 0.9,
                                  strokeColor: '#333333',
                                  fillOpacity: 0.5,
                                  fillColor: '#ffffff' }
      },
      elseFilter: true
  })],

  editRules: [new OpenLayers.Rule({
      symbolizer: {"Line" : { strokeWidth: 2,
                              strokeColor: '#000000',
                              strokeOpacity: 0.8 },
                    "Point" : { pointRadius: 8,
                                strokeColor: '#000000',
                                strokeOpacity: 0.9,
                                strokeWidth: 2,
                                fillOpacity: 0.3,
                                fillColor: '#ffffff' },
                    "Polygon" : { strokeWidth: 2.5,
                                  strokeOpacity: 0.8,
                                  strokeColor: '#000000',
                                  fillColor: '#ffffff' }
      },
      elseFilter: true
  })],

  editStyle: function() {
    var styleMap = new OpenLayers.StyleMap();
    styleMap.styles["default"].addRules(this.editRules);
    styleMap.styles["select"].addRules(this.editRules);
    styleMap.styles["temporary"].addRules(this.editRules);
    return styleMap;
  },

  displayStyle: function() {
    var styleMap = new OpenLayers.StyleMap();
    styleMap.styles["default"].addRules(this.displayRules);
    styleMap.styles["select"].addRules(this.displayRules);
    return styleMap;
  }
}
