MapStyle = {
  displayRules: [
    new OpenLayers.Rule({
        filter: new OpenLayers.Filter.Comparison({
          type: OpenLayers.Filter.Comparison.GREATER_THAN,
          property: "size_ratio",
          value: 0.1,
        }),
        symbolizer: {"Line" : { strokeWidth: 8,
                                strokeColor: '#333333',
                                graphicZIndex: 2,
                                strokeOpacity: 0.9 },
                      "Point" : { graphicWidth: 32,
                                  graphicOpacity: 1.0,
                                  graphicYOffset: -32,
                                  graphicZIndex: 3,
                                  externalGraphic: '${thumbnail}' },
                      "Polygon" : { strokeWidth: 2.5,
                                    strokeOpacity: 0.9,
                                    strokeColor: '#333333',
                                    fillOpacity: 0.1,
                                    graphicZIndex: 1,
                                    fillColor: '#ffffff' }
        },
        elseFilter: false
    }),
    new OpenLayers.Rule({
        symbolizer: {"Line" : { strokeWidth: 8,
                                strokeColor: '#333333',
                                graphicZIndex: 2,
                                strokeOpacity: 0.9 },
                      "Point" : { graphicWidth: 32,
                                  graphicOpacity: 1.0,
                                  graphicYOffset: -32,
                                  graphicZIndex: 3,
                                  externalGraphic: '${thumbnail}' },
                      "Polygon" : { strokeWidth: 2.5,
                                    strokeOpacity: 0.9,
                                    strokeColor: '#333333',
                                    fillOpacity: 0.5,
                                    graphicZIndex: 1,
                                    fillColor: '#ffffff' }
        },
        elseFilter: true
    })
  ],
  displaySelectRules: [new OpenLayers.Rule({
      symbolizer: {"Line" : { strokeWidth: 8,
                              strokeColor: '#007000',
                              graphicZIndex: 5,
                              strokeOpacity: 0.9 },
                      "Point" : { graphicWidth: 32,
                                  graphicOpacity: 1.0,
                                  graphicYOffset: -32,
                                  graphicZIndex: 5,
                                  externalGraphic: '${thumbnail}' },
                    "Polygon" : { strokeWidth: 2.5,
                                  strokeOpacity: 0.9,
                                  strokeColor: '#007000',
                                  fillOpacity: 0.5,
                                  graphicZIndex: 5,
                                  fillColor: '#ccffcc' }
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
    styleMap.styles["select"].addRules(this.displaySelectRules);
    return styleMap;
  },

  collisionStyle: function() {
    var lookup = {
      fatal: { strokeColor: '#aa0000', fillColor: '#ff0000', pointRadius: 10 },
      serious: { strokeColor: '#e44500', fillColor: '#ff8814', pointRadius: 8 },
      slight: { strokeColor: '#a7932f', fillColor: '#fcff00', pointRadius: 6 }
    }
    var styleMap = new OpenLayers.StyleMap();
    styleMap.addUniqueValueRules("default", "severity", lookup);
    styleMap.addUniqueValueRules("select", "severity", lookup);
    return styleMap;
  }
}
