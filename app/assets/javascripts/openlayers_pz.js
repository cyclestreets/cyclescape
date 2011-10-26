/**
 * Class: OpenLayers.Control.PZ
 *
 * Inherits from:
 *  - <OpenLayers.Control.PanZoom>
 *
 * Subclassed to avoid using the 'whole world' button.
 */

OpenLayers.Control.PZ = OpenLayers.Class(OpenLayers.Control.PanZoom, {

    initialize: function() {
        OpenLayers.Control.PanZoom.prototype.initialize.apply(this, arguments);
    },


    /**
     * Method: draw
     *
     * Parameters:
     * px - {<OpenLayers.Pixel>}
     *
     * Returns:
     * {DOMElement} A reference to the container div for the PanZoom control.
     */
    draw: function(px) {
        // initialize our internal div
        OpenLayers.Control.prototype.draw.apply(this, arguments);
        px = this.position;

        // place the controls
        this.buttons = [];

        var sz = new OpenLayers.Size(18,18);
        var centered = new OpenLayers.Pixel(px.x+sz.w/2, px.y);

        this._addButton("panup", "north-mini.png", centered, sz);
        px.y = centered.y+sz.h;
        this._addButton("panleft", "west-mini.png", px, sz);
        this._addButton("panright", "east-mini.png", px.add(sz.w, 0), sz);
        this._addButton("pandown", "south-mini.png",
                        centered.add(0, sz.h*2), sz);
        this._addButton("zoomin", "zoom-plus-mini.png",
                        centered.add(0, sz.h*3+5), sz);
        this._addButton("zoomout", "zoom-minus-mini.png",
                        centered.add(0, sz.h*4+5), sz);
        return this.div;
    },


    CLASS_NAME: "OpenLayers.Control.PZ"
});