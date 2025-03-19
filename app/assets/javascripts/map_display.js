/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS104: Avoid inline assignments
 * DS203: Remove `|| {}` from converted for-own loops
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Cls = (window.LeafletMap = class LeafletMap {
  static initClass () {
    this.default_marker_anchor = [30 / 2, 42]
  }
  static cyclestreetsPeekImg (feature) {
    const {
      thumbnailUrl
    } = feature.properties
    let peekImgEl = ''
    if (thumbnailUrl) {
      peekImgEl = '<img class="no-float" src="' + thumbnailUrl + '" alt="Image loading &hellip;"/>'
    }
    // Wrap image in a link
    return '<a title="Click for a bigger image and copyright details" href="' +
      CONSTANTS.geocoder.cyclestreetsUrl + '/location/' + feature.properties.id + '/" target="_blank">' + peekImgEl + '</a>'
  }

  // Used in cyclestreets photo search
  static updateCyclestreetsPhotoForm (form, feature) {
    const $form = $(form).closest('#new-cyclestreets-photo-message')

    $form.find('#image-preview').html(this.cyclestreetsPeekImg(feature))
    $form.find("textarea[id$='caption']").changeVal(feature.properties.caption)
    $form.find("input[id$='cyclestreets_id']").changeVal(feature.properties.id)
    $form.find("input[id$='photo_url']").changeVal(feature.properties.thumbnailUrl)
    $form.find("input[id$='icon_properties']").changeVal(JSON.stringify(feature.properties.iconProperties))
    return $form.find("input[id$='loc_json']").changeVal(JSON.stringify(feature))
  }

  constructor (center, opts) {
    this.addLayers = this.addLayers.bind(this)
    this.buildPhotoLayer = this.buildPhotoLayer.bind(this)
    this.buildCollistionLayer = this.buildCollistionLayer.bind(this)
    this.addSearchControl = this.addSearchControl.bind(this)
    this.drawFeatureId = this.drawFeatureId.bind(this)
    this.drawCircle = this.drawCircle.bind(this)
    this.drawFeature = this.drawFeature.bind(this)
    this.drawnLayerChanged = this.drawnLayerChanged.bind(this)
    this.addDraw = this.addDraw.bind(this)
    this.domId = opts.domid || 'map'
    const maxZoom = (opts.hidezoom != null) ? 15 : 18
    this.map = L.map(this.domId, {maxZoom})
    if (opts.hidekey == null) {
      this.map.attributionControl.setPrefix('').addAttribution(
        `\
<a
  href="${CONSTANTS.images.mapKey}"
  onclick="
    window.open(
      this.href,
      'mapKey',
      'toolbar=no,location=no,status=no,menubar=no,scrollbars=no,resizable=no,width=441,height=507'
    );
    return false;
  "
>
  Map key
</a>\
`
      ).setPosition('bottomleft')
    }
    this.setCenter(center)
    this.map.on('baselayerchange', e => window.localStorage.setItem('map.baselayer.name', e.name))
    this.geoInput = $(`#${opts.geoinput}_loc_json`)
    if (opts.collisions != null) { this.buildCollistionLayer() }
    if (opts.photos || opts.photoselect) { this.buildPhotoLayer(opts.photoselect) }
    this.remoteJSONLayer = {}
    if (opts.remote) {
      for (let remoteLayer of Array.from(opts.remote)) { this.buildRemoteLayer(remoteLayer) }
    }
    this.addLayers(opts)
    if (!opts.nosearch) { this.addSearchControl() }
    this.deletePopup = opts.deletepopup
    if (opts.draw != null) {
      this.addDraw(opts.feature)
    } else if (opts.feature != null) {
      this.addStaticFeature(opts.feature)
    }
    if (opts.hidezoom != null) { this.map.removeControl(this.map.zoomControl) }
    if (opts.zoomposition) { this.map.zoomControl.setPosition(opts.zoomposition) }
    this.drawnFeatures = {}

    // Maps not on the first tab do not render properly.  Force a re-render when changing jQueryUI tabs
    // tabsactivate is the event that jQueryUI emits.
    $(document).on('tabsactivate', () => {
      this.map.invalidateSize()
      this.setCenter(center)
    })
    return this
  }

  featurePointToLayer (feature, latlng) {
    if (!feature.properties.thumbnail) { return L.marker(latlng) }
    const icon = new L.Icon({iconUrl: feature.properties.thumbnail, iconAnchor: feature.properties.anchor})
    return L.marker(latlng, {icon})
  }

  addStaticFeature (collection) {
    L.geoJson(collection, {
      style: {color: 'black'}, pointToLayer: this.featurePointToLayer
    }).addTo(this.map)
  }

  buildRemoteLayer (opts) {
    const {
      featurePointToLayer
    } = this
    this.remoteJSONLayer[opts.name] = new L.LayerJSON({
      url: `${opts.url}?bbox={lon1},{lat1},{lon2},{lat2}`,
      propertyItems: 'features',
      propertyLoc: 'geometry.coordinates',
      caching: false,
      propertyId: 'id',
      minShift: 10,
      dataToMarker (data) {
        return L.geoJson(data, {
          pointToLayer: featurePointToLayer,
          fillOpacity: 0.1,
          fillColor: 'white',
          color: opts.color || '#03f',
          onEachFeature (feature, layer) {
            const img = feature.properties.image_url
              ? `<img src='${feature.properties.image_url}' width='37' height='37'>` : undefined
            const createdBy = feature.properties.created_by ? `<p>created by <a href='${feature.properties.created_by_url}'> ${feature.properties.created_by} </p>` : ''
            layer.bindPopup(`${img || ''} <h3><a href='${feature.properties.url}'> ${feature.properties.title} </a></h3> ${createdBy}`)
          }
        }
        )
      }
    }).addTo(this.map)
  }

  setCenter (center) {
    if (center.fitBounds != null) { this.map.fitBounds(center.fitBounds) }
    if (center.latLon) { this.map.setView(center.latLon, center.zoom) }
  }

  addLayers (opts) {
    let needle
    let tileServer
    if (opts == null) { opts = {} }
    this.baseLayers = {}
    let existingBaseName = window.localStorage.getItem('map.baselayer.name')
    const tileServers = $('#map-tiles').data('tileservers')
    if (!tileServers.some(tileServer => tileServer.name === existingBaseName)) {
      existingBaseName = null
    }
    for (let idx = 0; idx < tileServers.length; idx++) {
      tileServer = tileServers[idx]
      if ((tileServer.url === '') || (tileServer.name === '')) { continue }
      const options = jQuery.parseJSON(tileServer.options)
      const tileLayer = tileServer.type === 'wms'
        ? L.tileLayer.wms(tileServer.url, options)
        : L.tileLayer(tileServer.url, options)
      this.baseLayers[tileServer.name] = tileLayer
      if ((existingBaseName === tileServer.name) || (!existingBaseName && (idx === 0))) {
        tileLayer.addTo(this.map)
      }
    }

    const additionalLayers = this.remoteJSONLayer
    if (this.collisionLayer) { additionalLayers['Collisions'] = this.collisionLayer }
    if (this.photoLayer) { additionalLayers['Photos'] = this.photoLayer }

    if (!opts.hidelayers) { L.control.layers(this.baseLayers, additionalLayers).addTo(this.map) }
    if (opts.photoselect) { return this.map.addLayer(this.photoLayer) }
  }

  buildPhotoLayer (photoselect) {
    const params = [
      {name: 'key', value: $('#map-geocode').data('key') || CONSTANTS.geocoder.apiKey},
      {name: 'fields',
        value: 'id,name,hasPhoto,categoryId,categoryPlural,metacategoryName,iconProperties,thumbnailUrl'},
      {name: 'thumbnailsize', value: 2000},
      {name: 'datetime', value: 'friendly'}
    ]
    $('[data-behaviour="search-cyclestreets"]').click(e => {
      e.preventDefault()
      return $.get(CONSTANTS.geocoder.photoLocationUrl + '?' + $.param(params.concat({name: 'id', value: $('#photo_id_').val()})))
        .done(json => {
          const feature = json.features[0]
          this.popUpID = feature.properties.id
          this.map.fitBounds(L.geoJson(feature).getBounds())
        })
    })

    this.photoLayer = new L.LayerJSON({
      url: `${CONSTANTS.geocoder.photoUrl}?${$.param(params)}&bbox={lon1},{lat1},{lon2},{lat2}`,
      propertyItems: 'features',
      propertyLoc: 'geometry.coordinates',
      locAsGeoJSON: true,
      propertyId: 'properties.id',
      minShift: 10,
      caching: false,
      dataToMarker: (feature, latlng) => {
        const {
          iconProperties
        } = feature.properties
        iconProperties.iconUrl = CONSTANTS.geocoder.cyclestreetsUrl + iconProperties.iconUrl
        iconProperties.shadowUrl = CONSTANTS.geocoder.cyclestreetsUrl + iconProperties.shadowUrl
        const icon = new L.Icon(iconProperties)
        const marker = new L.marker(latlng, {icon})
        // Declarations
        const { id } = feature.properties
        // Get caption
        const caption = `<p class="caption">${feature.properties.caption}</p>`
        // Headline
        let headline = '<p></p>'
        if (feature.properties.hasOwnProperty('categoryPlural') && feature.properties.hasOwnProperty('metacategoryName')) {
          headline += `<p class=\"categorisationnote small\">Categorisation: ${feature.properties.categoryPlural} (${feature.properties.metacategoryName.toLowerCase()})</p>`
        }
        // The main bit of the content
        const mainContent = '<p class="peekimage">' + this.constructor.cyclestreetsPeekImg(feature) + '</p>'
        const selectable = photoselect
          ? `<div class='formtastic btn-green' id='cs-image-${feature.properties.id}'> ${CONSTANTS.i18n.selectImage} </button>`
          : ''

        const popup = marker.bindPopup('<div class="photo bubble">' + headline + mainContent + caption + selectable + '</div>').on('click', () => $(`#cs-image-${feature.properties.id}`).click(e => window.LeafletMap.updateCyclestreetsPhotoForm(e.target, feature)))
        if (this.popUpID === id) { popup.openPopup() }

        return marker
      }
    })

    // https://github.com/stefanocudini/leaflet-layerJSON/issues/19
    const oldOnRemove = this.photoLayer.onRemove.bind(this.photoLayer)
    this.photoLayer.onRemove = function (map) {
      oldOnRemove(map)
      this._markersCache = {}
    }
  }

  buildCollistionLayer () {
    const lookup = {
      fatal: { color: '#aa0000', fillColor: '#ff0000', radius: 10 },
      serious: { color: '#e44500', fillColor: '#ff8814', radius: 8 },
      slight: { color: '#a7932f', fillColor: '#fcff00', radius: 6 }
    }
    const params = [
      {name: 'key', value: $('#map-geocode').data('key') || CONSTANTS.geocoder.apiKey},
      {name: 'fields', value: 'id,latitude,longitude,datetime,severity,url'},
      {name: 'datetime', value: 'friendly'}
    ]
    this.collisionLayer = new L.LayerJSON({
      url: `${CONSTANTS.geocoder.collisionsUrl}?${$.param(params)}&bbox={lon1},{lat1},{lon2},{lat2}`,
      propertyItems: 'features',
      propertyLoc: ['properties.latitude', 'properties.longitude'],
      minShift: 10,
      caching: false,
      propertyId: 'properties.id',
      dataToMarker: (feature, latlng) => {
        const props = lookup[feature.properties.severity]
        const marker = new L.CircleMarker(latlng, props)
        marker.bindPopup(
          `<h3><a href=\"${feature.properties.url}\">Collision ${feature.properties.id}</a></h3> \
<p>Date and time: ${feature.properties.datetime} </p> \
<p>Severity: ${feature.properties.severity} </p> \
<p><a href=\"${feature.properties.url}\">View on CycleStreets</a></p>`
        )
        return marker
      }
    })

    // https://github.com/stefanocudini/leaflet-layerJSON/issues/19
    const oldOnRemove = this.collisionLayer.onRemove.bind(this.collisionLayer)
    return this.collisionLayer.onRemove = function (map) {
      oldOnRemove(map)
      return this._markersCache = {}
    }
  }

  addSearchControl (opts) {
    if (opts == null) { opts = {} }
    const formatJSON = function (rawjson) {
      const json = {}
      const featureName = props => `${props.name} (${props.near})`

      for (let feature of Array.from(rawjson.features)) {
        const nesw = feature.properties.bbox.split(',').reverse()
        const latlng = L.latLng(feature.geometry.coordinates.reverse())
        latlng.bounds = L.latLngBounds(nesw.slice(2), nesw.slice(0, 2)) // add the bounds (for getting zoom later) in format S,W,N,E
        json[featureName(feature.properties)] = latlng
      }
      return json
    }

    const search = (text, callback) => {
      const bbox = this.map.getBounds().toBBoxString()
      const params = [
        {name: 'q', value: text},
        {name: 'key', value: $('#map-geocode').data('key') || CONSTANTS.geocoder.apiKey},
        {name: 'bbox', value: bbox}
      ]

      return $.ajax({
        url: $('#map-geocode').data('url') || CONSTANTS.geocoder.geoUrl,
        data: params,
        timeout: 10000,
        success: callback
      })
    }

    const defaultOpts = {
      autoCollapse: true,
      sourceData: search,
      formatData: formatJSON,
      moveToLocation (latlng, _title, map) {
        return map.fitBounds(latlng.bounds)
      },
      autoType: false,
      filterData (_, records) { return records },
      minLength: 2
    }
    const searchControl = new (L.Control.Search)($.extend(defaultOpts, opts))
    this.map.addControl(searchControl)
    return searchControl
  }

  drawFeatureId (feature, id) {
    if (this.drawnFeatures[id]) {
      this.drawnItems.removeLayer(this.drawnFeatures[id])
      this.drawnLayerChanged()
    }
    if (feature) {
      feature = L.geoJson(feature).getLayers()[0]
      this.drawFeature(feature)
      this.map.fitBounds(feature.getBounds())
    }
    return this.drawnFeatures[id] = feature
  }

  drawCircle (latLng) {
    let circle
    if (latLng) {
      const lat = latLng.lat || latLng.latitude || latLng[0]
      const lng = latLng.lng || latLng.longitude || latLng[1]
      const nPoints = 10
      const earthRadius = 6378137
      const radius = 500 / earthRadius
      const center = L.Projection.SphericalMercator.project({lat, lng})

      const offset = function (iTheta) {
        const theta = ((2.0 * Math.PI) / nPoints) * iTheta
        const x = radius * Math.cos(theta)
        const y = radius * Math.sin(theta)
        return L.Projection.SphericalMercator.unproject({x: center.x + x, y: center.y + y})
      }

      const points = []
      for (let theta = 0; theta < nPoints; theta++) {
        points.push(offset(theta))
      }
      circle = new L.Polygon(points).toGeoJSON()
    }
    return this.drawFeatureId(circle, 'circle')
  }

  drawFeature (layer) {
    this.drawnItems.addLayer(layer)
    if (this.deletePopup) {
      const domelem = document.createElement('a')
      domelem.innerHTML = `${CONSTANTS.i18n.delete}?</a>`
      domelem.onclick = () => {
        this.drawnItems.removeLayer(layer)
        return this.drawnLayerChanged()
      }
      this.drawnItems.bindPopup(domelem)
    }
    return this.drawnLayerChanged()
  }

  drawnLayerChanged () {
    this.geoInput.changeVal(JSON.stringify(this.drawnItems.toGeoJSON()))
    if (this._editing) { $("a[title='Save changes.']")[0].click() }
    return $('.leaflet-draw-edit-edit')[0].click()
  }

  addDraw (feature) {
    let layer
    for (let _ in this.baseLayers) { layer = this.baseLayers[_]; layer.setOpacity(0.7) }

    this.drawnItems = new L.FeatureGroup()
    $('.icon-save').toggle()

    this.map.addLayer(this.drawnItems)
    const drawControl = new L.Control.Draw({
      position: 'topright',
      edit: {
        featureGroup: this.drawnItems,
        edit: { selectedPathOptions: { fillColor: '#00008B', maintainColor: true } }
      },
      draw: {
        circle: false,
        rectangle: false,
        polygon: {
          shapeOptions: { color: '#00008B', opacity: 0.75 }
        },
        polyline: {
          shapeOptions: { color: '#00008B', opacity: 0.75 }
        },
        marker: {
          icon: new L.Icon({
            iconUrl: CONSTANTS.images.defaultMarker,
            iconAnchor: this.constructor.default_marker_anchor
          })
        }
      }
    })

    this.map.addControl(drawControl)

    this.map.on('draw:created', e => {
      return this.drawFeature(e.layer)
    })

    this.map.on('draw:editstart', () => {
      return this._editing = true
    })

    this.map.on('draw:editstop', () => {
      return this._editing = false
    })

    this.map.on('draw:edited draw:editvertex draw:drawvertex draw:editmove draw:deleted', e => {
      if (!this._editing) { return }
      for (layer of this.drawnItems.getLayers()) {
        this.drawFeature(layer)
      }
    })

    if (feature) {
      for (layer of Array.from(L.geoJson(feature).getLayers())) { this.drawFeature(layer) }
    } else {
      // enable point / marker draw as standard
      $('.leaflet-draw-draw-marker')[0].click()
      $('.icon-undo').css({opacity: 0.3})
    }

    // Bind our icons to the Leaflet draw icons
    const lDrawMapping = {
      area: 'polygon',
      route: 'polyline',
      point: 'marker'
    }

    for (let localN of Object.keys(lDrawMapping || {})) {
      const lDrawName = lDrawMapping[localN]
      $(`li.${localN} a`).click(function (evt) {
        evt.preventDefault()
        evt.stopPropagation()
        return $(`.leaflet-draw-draw-${lDrawMapping[evt.target.className]}`)[0].click()
      })
    }

    const $useGroupLocation = $('#use-group-location')
    $useGroupLocation.click(evt => {
      evt.preventDefault()
      evt.stopPropagation()
      this.drawnItems.clearLayers()
      const groupLocation = $useGroupLocation.data('location')
      this.geoInput.changeVal(groupLocation)
      const geoJson = L.geoJson(groupLocation)
      for (layer of Array.from(geoJson.getLayers())) { this.drawFeature(layer) }
      return this.map.fitBounds(geoJson.getBounds())
    })

    // Otherwise clear wipes any shapes on the map
    $('.edit-clear').click(evt => {
      evt.preventDefault()
      evt.stopPropagation()
      this.drawnItems.clearLayers()
      __guard__($('ul.leaflet-draw-actions a[title^="Cancel"]')[0], x => x.click())
      $('.tabs').children('li.area, li.route, li.point').css({opacity: 1}).prop('disabled', false)
      this.geoInput.changeVal(null)
      $('.icon-undo').css({opacity: 0.3})
      const activeTab = $('.tabs').parent().tabs('option', 'active')
      return $('.tabs a span')[activeTab].click()
    }) // Re-activate drawing the current shape

    this.map.on('draw:drawstart', e => $('.icon-undo').css({opacity: 1}))

    // Undo removes the last point if creating
    // or the last feature if not creating
    $('.edit-undo').click(function (evt) {
      evt.preventDefault()
      evt.stopPropagation()
      if (__guard__(__guard__(this.drawnItems.getLayers().slice(-1)[0], x1 => x1.editing), x => x._enabled)) {
        return this.drawnItems.removeLayer(this.drawnItems.getLayers().slice(-1)[0])
      } else {
        return $('ul.leaflet-draw-actions a[title^="Delete"]')[0].click()
      }
    })
  }
})
Cls.initClass()

window.leafletMapInit = () => {
  const result = []
  for (let mapData of $('.map-data')) {
    const domMap = $(mapData)
    if (!domMap.data('skip')) { new LeafletMap(domMap.data('center'), domMap.data('opts')) }
    result.push(domMap.data('skip', true))
  }
  return result
}

function __guard__ (value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined
}
