MapStyle = {
  displayRules: [new OpenLayers.Rule({
      symbolizer: {"Line" : { strokeWidth: 8,
                              strokeColor: '#00ff00',
                              strokeOpacity: 0.8 },
                    "Point" : { pointRadius: 8,
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
                                fillColor: '#000000' },
                    "Polygon" : { strokeWidth: 2.5,
                                  strokeOpacity: 0.8,
                                  strokeColor: '#000000',
                                  fillColor: '#000000' }
      },
      elseFilter: true
  })],

  editStyle: function() {
    var styleMap = new OpenLayers.StyleMap();
    styleMap.styles["default"].addRules(this.displayRules);
    styleMap.styles["select"].addRules(this.displayRules);
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
