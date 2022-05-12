// Remove calls to disableTextSelection and focus
// https://github.com/Leaflet/Leaflet.draw/blob/v0.4.7/src/draw/handler/Draw.Feature.js#L57-L59
L.Draw.Feature.prototype.addHooks = function () {
  var map = this._map;

  if (map) {
    this._tooltip = new L.Draw.Tooltip(this._map);

    L.DomEvent.on(this._container, 'keyup', this._cancelDrawing, this);
  }
}
