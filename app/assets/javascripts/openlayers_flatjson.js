/* Copyright (c) 2006-2011 by OpenLayers Contributors (see authors.txt for
 * full list of contributors). Published under the Clear BSD license.
 * See http://svn.openlayers.org/trunk/openlayers/license.txt for the
 * full text of the license. */

/**
 * @requires OpenLayers/Format/JSON.js
 * @requires OpenLayers/Feature/Vector.js
 * @requires OpenLayers/Geometry/Point.js
 * @requires OpenLayers/Geometry/MultiPoint.js
 * @requires OpenLayers/Geometry/LineString.js
 * @requires OpenLayers/Geometry/MultiLineString.js
 * @requires OpenLayers/Geometry/Polygon.js
 * @requires OpenLayers/Geometry/MultiPolygon.js
 * @requires OpenLayers/Console.js
 */

/**
 * Class: OpenLayers.Format.FlatJSON
 * Read JSON POI documents with no GeoJSON structure.
 * Create a new parser with the
 *     <OpenLayers.Format.FlatJSON> constructor.
 *
 * Inherits from:
 *  - <OpenLayers.Format>
 */
OpenLayers.Format.FlatJSON = OpenLayers.Class(OpenLayers.Format, {

    /**
     * Method: getResultArray
     * Return the Array that cointains the items from
     *     the obj. Method to be overriden
     *
     * Parameters:
     * obj - {Object} An object created from a JSON document
     *
     * Returns:
     * <Object> An array of items.
     */
    getResultArray: function(obj){ return obj.results},

    /**
     * Method: getLat
     * Return the latitude value contained in the obj.
     *     Method to be overriden
     *
     * Parameters:
     * obj - {Object} An object item from a JSON object
     *
     * Returns:
     * A number
     */
    getLat: function(obj){ return obj.lat },
    /**
     * Method: getLon
     * Return the longitude value contained in the obj.
     *     Method to be overriden
     *
     * Parameters:
     * obj - {Object} An object item from a JSON object
     *
     * Returns:
     * A number
     */
    getLon: function(obj){ return obj.lon },

    read: function(json, type, filter) {
        var results = null;
        var obj = null;
        if (typeof json == "string") {
            obj = OpenLayers.Format.JSON.prototype.read.apply(this,
                                                              [json, filter]);
        } else {
            obj = json;
        }
        if(!obj) {
            OpenLayers.Console.error("Bad JSON: " + json);
            return;
        }
        var res = this.getResultArray(obj);
        if (!res){
            alert("no results");
            OpenLayers.Console.error("Can't find the results Array : "+ json);
            return;
        }
        results = this.parseFeatures(res,this);
        return results;
    },

    parseFeatures: function(obj,format){
        var features = [];
        for (var i = 0; i< obj.length; i++){
            var feat = this.parseFeature(obj[i],format);
            if (feat) features.push(feat);
        }
        return features;
    },


    /**
     * Method: parseFeature
     * Convert an object item from a JSON into an
     *     <OpenLayers.Feature.Vector>.
     *
     * Parameters:
     * obj - {Object} An object created from a GeoJSON object
     *
     * Returns:
     * {<OpenLayers.Feature.Vector>} A feature.
     */
    parseFeature: function(obj,format) {
        var feature, geometry, attributes, bbox;
        attributes=new Object();
        for (att in obj){
            attributes[att]=obj[att];
        }

        try {
            var lat, lon;
            lat = format.getLat(obj);
            lon = format.getLon(obj);
            if (isNaN(parseFloat(lat)) || !isFinite(lat)) return;
            if (isNaN(parseFloat(lon)) || !isFinite(lon)) return;
            geometry = new OpenLayers.Geometry.Point(lon,lat);
        } catch(err) {
            // deal with bad geometries
            //throw err;
            return;
        }

        bbox = (geometry && geometry.bbox) || obj.bbox;

        feature = new OpenLayers.Feature.Vector(geometry, attributes);
        if(bbox) {
            feature.bounds = OpenLayers.Bounds.fromArray(bbox);
        }
        if(obj.id) {
            feature.fid = obj.id;
        }
        return feature;
    },


    CLASS_NAME: "OpenLayers.Format.FlatJSON"

});