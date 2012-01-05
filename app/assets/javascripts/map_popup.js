/**
 *
 * Displaying popups
 *
 */

MapPopup = {
  map: null,
  layer: null,

  init: function(m, l) {
    this.map = m;
    this.layer = l;
    m.addControl(new OpenLayers.Control.SelectFeature(l, {id: 'selector', onSelect: MapPopup.createPopup, onUnselect: MapPopup.destroyPopup }));
    m.getControl('selector').activate();
  },

  createPopup: function(feature) {
      feature.popup = new OpenLayers.Popup.FramedCloud("pop",
          feature.geometry.getBounds().getCenterLonLat(),
          null,
          '<h3><a href="' + feature.attributes.url + '">' + feature.attributes.title + '</a></h3>' +
            '<p>created by <a href="' + feature.attributes.created_by_url + '">' + feature.attributes.created_by + '</p>',
          null,
          true,
          function() { MapPopup.map.getControl('selector').unselectAll(); }
      );
      map.addPopup(feature.popup);
  },

  destroyPopup: function(feature) {
      feature.popup.destroy();
      feature.popup = null;
  }
}