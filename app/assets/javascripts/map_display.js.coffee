require('leaflet-search/dist/leaflet-search.src.js')
require('leaflet-draw')

class window.LeafletMap
  @OpenCycle: 'https://{s}.tile.cyclestreets.net/opencyclemap/{z}/{x}/{y}@2x.png'
  @OSStreet: 'https://{s}.tile.cyclestreets.net/osopendata/{z}/{x}/{y}.png'
  @Mapnik: 'https://{s}.tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png'
  @CyclestreetsUrl: "https://www.cyclestreets.net"
  @default_marker_anchor: [30 / 2, 42]
  @drawnItems: new L.FeatureGroup()

  constructor: (center, opts) ->
    @domId = opts.domid || 'map'
    @map = L.map(@domId, maxZoom: 18)
    @map.attributionControl.setPrefix('')
    @setCenter(center)
    @geoInput = $("##{opts.geoinput}_loc_json")
    @buildCollistionLayer() if opts.collisions?
    @buildPhotoLayer(opts.photoselect) if opts.photos or opts.photoselect
    @remoteJSONLayer = {}
    @buildRemoteLayer(url, name) for own name, url of opts.remote
    @addLayers(opts)
    @addSearchControl() if opts.search
    if opts.draw?
      @addDraw(opts.feature)
    else if opts.feature?
      @addStaticFeature(opts.feature)
    @map.removeControl(@map.zoomControl) if opts.hidezoom?
    @map.zoomControl.setPosition(opts.zoomposition) if opts.zoomposition
    @drawnFeatures = {}
    @

  featurePointToLayer: (feature, latlng) =>
    return L.marker(latlng).addTo @map unless feature.properties.thumbnail
    icon = new L.Icon(iconUrl: feature.properties.thumbnail, iconAnchor: feature.properties.anchor)
    L.marker(latlng, {icon: icon}).addTo @map

  addStaticFeature: (collection) ->
    L.geoJson(collection, {
      style: {color: 'black'}, pointToLayer: @featurePointToLayer
    }).addTo @map
    return

  buildRemoteLayer: (url, name) ->
    remoteLayer = L.geoJson(null, {
      pointToLayer: @featurePointToLayer.bind(@)
      fillOpacity: 0.1
      fillColor: 'white'
      onEachFeature: (feature, layer) ->
        img = if feature.properties.image_url
          "<img src='#{feature.properties.image_url}' width='37' height='37'>"
        else
          ''
        layer.bindPopup( "#{img}
         <h3><a href='#{feature.properties.url}'> #{feature.properties.title} </a></h3>
         <p>created by <a href='#{feature.properties.created_by_url}'> #{feature.properties.created_by} </p>"
        )
    }).addTo(@map)
    @remoteJSONLayer[name] = new L.LayerJSON({
      url: "#{url}?bbox={lon1},{lat1},{lon2},{lat2}"
      propertyItems: 'features'
      propertyLoc: 'geometry.coordinates'
      updateOutBounds: false
      minShift: 500
      hashGenerator: (data) ->
        data.id
      dataToMarker: remoteLayer.addData.bind(remoteLayer)
    }).addTo(@map)

  setCenter: (center) ->
    @map.fitBounds(center.fitBounds) if center.fitBounds?
    @map.setView(center.latLon, center.zoom) if center.latLon
    return

  addLayers: (opts = {}) ->
    opacity = opts.opacity || 0.8
    openCycle = L.tileLayer(@constructor.OpenCycle, opacity: opacity)
    openCycle.addTo(@map)
    baseLayers = {
      "OpenCycleMap":  openCycle
      "OS StreetView": L.tileLayer(@constructor.OSStreet, opacity: opacity)
      "OpenStreetMap": L.tileLayer(@constructor.Mapnik, opacity: opacity)
    }
    additionalLayers = @remoteJSONLayer
    additionalLayers['Collisions'] = @collisionLayer if @collisionLayer
    additionalLayers['Photos'] = @photoLayer if @photoLayer

    L.control.layers(baseLayers, additionalLayers).addTo(@map) unless opts.hidelayers
    @map.addLayer @photoLayer if opts.photoselect

  buildPhotoLayer: (photoselect) =>
    params = [
      {name: 'key', value: CONSTANTS.geocoder.apiKey},
      {name: 'fields',
      value: 'id,name,hasPhoto,categoryId,categoryPlural,metacategoryName,iconProperties,thumbnailUrl'},
      {name: 'thumbnailsize', value: 2000},
      {name: 'datetime', value: 'friendly'},
    ]

    @photoLayer = new L.LayerJSON({
      url: "#{CONSTANTS.geocoder.photoUrl}?#{$.param(params)}&bbox={lon1},{lat1},{lon2},{lat2}"
      propertyItems: 'features'
      propertyLoc: 'geometry.coordinates'
      locAsGeoJSON: true
      minShift: 200
      dataToMarker: (feature, latlng) =>
        return unless feature.properties.hasPhoto
        iconProperties = feature.properties.iconProperties
        iconProperties.iconUrl = @constructor.CyclestreetsUrl + iconProperties.iconUrl
        iconProperties.shadowUrl = @constructor.CyclestreetsUrl + iconProperties.shadowUrl
        icon = new L.Icon(iconProperties)
        marker = new L.marker(latlng, {icon: icon}).addTo @photoLayer
        # Declarations
        id = feature.properties.id
        thumbnailUrl = feature.properties.thumbnailUrl
        latitude = feature.geometry.coordinates[1]
        longitude = feature.geometry.coordinates[0]
        peekImgEl = if thumbnailUrl
          '<img class="no-float" src="' + thumbnailUrl + '" alt="Image loading &hellip;"/>'
        else
          ''
        # Wrap image in a link
        peekImgEl = "<a title=\"Click for a bigger image and copyright details\" href=\"" +
          @constructor.CyclestreetsUrl + "/location/#{id}/\" target=\"_blank\">#{peekImgEl}</a>"
        # Get caption
        caption = "<p class=\"caption\">#{feature.properties.caption}</p>"
        # Headline
        headline = '<p></p>'
        if feature.properties.hasOwnProperty('categoryPlural') and feature.properties.hasOwnProperty('metacategoryName')
          headline += "<p class=\"categorisationnote small\">Categorisation: #{feature.properties.categoryPlural} (#{feature.properties.metacategoryName.toLowerCase()})</p>"
        # The main bit of the content
        mainContent = '<p class="peekimage">' + peekImgEl + '</p>'
        selectable = if photoselect
          "<div class='formtastic btn-green' id='cs-image-#{feature.properties.id}'> #{CONSTANTS.i18n.selectImage} </button>"
        else
          ""

        marker.bindPopup('<div class="photo bubble">' + headline + mainContent + caption + selectable + '</div>').on("click", ->
          $("#cs-image-#{feature.properties.id}").click ->
            $("#image-preview").html(peekImgEl)
            $("#cyclestreets_photo_message_caption").changeVal(feature.properties.caption)
            $("#cyclestreets_photo_message_cyclestreets_id").changeVal(feature.properties.id)
            $("#cyclestreets_photo_message_photo_url").changeVal(thumbnailUrl)
            $("#cyclestreets_photo_message_icon_properties").changeVal(JSON.stringify(iconProperties))
            $("#cyclestreets_photo_message_loc_json").changeVal JSON.stringify(feature)
        )
        return
    })

  buildCollistionLayer: =>
    lookup = {
      fatal: { color: '#aa0000', fillColor: '#ff0000', radius: 10 },
      serious: { color: '#e44500', fillColor: '#ff8814', radius: 8 },
      slight: { color: '#a7932f', fillColor: '#fcff00', radius: 6 }
    }
    params = [
      {name: 'key', value: CONSTANTS.geocoder.apiKey}
      {name: 'fields', value: 'id,latitude,longitude,datetime,severity,url'},
      {name: 'datetime', value: 'friendly'},
    ]
    @collisionLayer = new L.LayerJSON({
      url: "#{CONSTANTS.geocoder.collisionsUrl}?#{$.param(params)}&bbox={lon1},{lat1},{lon2},{lat2}"
      propertyItems: 'features'
      propertyLoc: ['properties.latitude','properties.longitude']
      minShift: 200
      dataToMarker: (feature, latlng) =>
        props = lookup[feature.properties.severity]
        marker = new L.CircleMarker(latlng, props).addTo @collisionLayer
        marker.bindPopup(
          "<h3><a href=\"#{feature.properties.url}\">Collision #{feature.properties.id}</a></h3>
          <p>Date and time: #{feature.properties.datetime} </p>
          <p>Severity: #{feature.properties.severity} </p>
          <p><a href=\"#{feature.properties.url}\">View on CycleStreets</a></p>"
        )
    })

  addSearchControl: (opts = {}) =>
    formatJSON = (rawjson) ->
      json = {}
      featureName = (props) ->
        "#{props.name} (#{props.near})"

      for feature in rawjson.features
        nesw = feature.properties.bbox.split(",").reverse()
        latlng = L.latLng(feature.geometry.coordinates.reverse())
        latlng.bounds = L.latLngBounds(nesw.slice(2), nesw.slice(0,2)) # add the bounds (for getting zoom later) in format S,W,N,E
        json[featureName(feature.properties)] = latlng
      json

    search = (text, callback) =>
      bbox = @map.getBounds().toBBoxString()
      params = [
        {name: 'q', value: text}
        {name: 'key', value: CONSTANTS.geocoder.apiKey}
        {name: 'bbox', value: bbox}
      ]

      $.ajax(
        url: CONSTANTS.geocoder.geoUrl
        data: params
        dataType: 'jsonp' if jsonpTransportRequired()
        timeout: 10000
        success: callback
      )

    defaultOpts = {
      autoCollapse: true
      sourceData: search
      formatData: formatJSON
      moveToLocation: (latlng, _title, map) ->
        map.fitBounds(latlng.bounds)
      autoType: false
      filterData: (_, records) -> records
      minLength: 2
    }
    searchControl = new (L.Control.Search)($.extend(defaultOpts, opts))
    @map.addControl(searchControl)
    searchControl

  drawFeatureId: (feature, id) =>
    if @drawnFeatures[id]
      @constructor.drawnItems.removeLayer @drawnFeatures[id]
    if feature
      feature = L.geoJson(feature).getLayers()[0]
      @drawFeature(feature)
      @map.fitBounds(feature.getBounds())
    @drawnFeatures[id] = feature

  drawCircle: (latLng) =>
    if latLng
      lat = latLng.lat || latLng.latitude || latLng[0]
      lng = latLng.lng || latLng.longitude || latLng[1]
      nPoints = 10
      earthRadius = 6378137
      radius = 500 / earthRadius
      center = L.Projection.SphericalMercator.project({lat: lat, lng: lng})

      offset = (iTheta) ->
        theta = 2.0 * Math.PI / nPoints * iTheta
        x = radius * Math.cos(theta)
        y = radius * Math.sin(theta)
        L.Projection.SphericalMercator.unproject({x: center.x + x, y: center.y + y})

      points = []
      points.push(offset(theta)) for theta in [0...nPoints]
      circle = new L.Polygon(points).toGeoJSON()
    @drawFeatureId(circle, "circle")

  drawFeature: (layer) =>
    @constructor.drawnItems.addLayer layer
    @drawnLayerChanged()

  drawnLayerChanged: =>
    @geoInput.changeVal JSON.stringify(@constructor.drawnItems.toGeoJSON())
    $("a[title='Save changes.']")[0].click() if @_editing
    $('.leaflet-draw-edit-edit')[0].click()

  addDraw: (feature) =>
    drawnItems = @constructor.drawnItems

    $('.icon-save').toggle()

    @map.addLayer drawnItems
    drawControl = new L.Control.Draw {
      position: 'topright'
      edit: {
        featureGroup: drawnItems
        edit: { selectedPathOptions: { fillColor: '#00008B', maintainColor: true } }
      }
      draw: {
        circle: false
        rectangle: false
        polygon: {
          shapeOptions: { color: '#00008B' }
        }
        polyline: {
          shapeOptions: { color: '#00008B' }
        }
        marker: {
          icon: new L.Icon {
            iconUrl: CONSTANTS.images.defaultMarker,
            iconAnchor: @constructor.default_marker_anchor
          }
        }
      }
    }

    @map.addControl drawControl

    @map.on 'draw:created', (e) =>
      @drawFeature(e.layer)

    @map.on 'draw:editstart', =>
      @_editing = true

    @map.on 'draw:editstop', =>
      @_editing = false

    @map.on 'draw:edited draw:editvertex draw:drawvertex draw:editmove draw:deleted', (e) =>
      return unless @_editing
      @drawFeature(layer) for layer in drawnItems.getLayers()

    if feature
      @drawFeature(layer) for layer in L.geoJson(feature).getLayers()
    else
      # enable area / polygon draw as standard
      $(".leaflet-draw-draw-polygon")[0].click()
      $('.icon-undo').css(opacity: 0.3)

    # Bind our icons to the Leaflet draw icons
    lDrawMapping = {
      area: "polygon"
      route: "polyline"
      point: "marker"
    }

    for own localN,lDrawName of lDrawMapping
      $("li.#{localN} a").click (evt) ->
        evt.preventDefault()
        evt.stopPropagation()
        $(".leaflet-draw-draw-#{lDrawMapping[evt.target.className]}")[0].click()

    # Otherwise clear wipes any shapes on the map
    $('.edit-clear').click (evt) =>
      evt.preventDefault()
      evt.stopPropagation()
      drawnItems.clearLayers()
      $('ul.leaflet-draw-actions a[title^="Cancel"]')[0]?.click()
      $('.tabs').children('li.area, li.route, li.point').css(opacity: 1).prop('disabled', false)
      @geoInput.changeVal(null)
      $('.icon-undo').css(opacity: 0.3)
      activeTab = $('.tabs').parent().tabs('option', 'active')
      $('.tabs a span')[activeTab].click() # Re-activate drawing the current shape

    @map.on 'draw:drawstart', (e) ->
      $('.icon-undo').css(opacity: 1)

    # Undo removes the last point if creating
    # or the last feature if not creating
    $('.edit-undo').click (e) ->
      evt.preventDefault()
      evt.stopPropagation()
      if drawnItems.getLayers().slice(-1)[0]?.editing?._enabled
        drawnItems.removeLayer(drawnItems.getLayers()[-1..][0])
      else
        $('ul.leaflet-draw-actions a[title^="Delete"]')[0].click()


jQuery ->
  for mapData in $('.map-data')
    domMap = $(mapData)
    new LeafletMap(domMap.data('center'), domMap.data('opts')) unless domMap.data('skip')
