require('leaflet-search/dist/leaflet-search.src.js')
require('leaflet-draw')
require('leaflet-layerjson')

class window.LeafletMap
  @default_marker_anchor: [30 / 2, 42]
  @cyclestreetsPeekImg: (feature)->
    thumbnailUrl = feature.properties.thumbnailUrl
    peekImgEl = ''
    if thumbnailUrl
      peekImgEl = '<img class="no-float" src="' + thumbnailUrl + '" alt="Image loading &hellip;"/>'
    # Wrap image in a link
    '<a title="Click for a bigger image and copyright details" href="' +
      CONSTANTS.geocoder.cyclestreetsUrl + '/location/' + feature.properties.id + '/" target="_blank">' + peekImgEl + '</a>'

  # Used in cyclestreets photo search
  @updateCyclestreetsPhotoForm: (form, feature)->
    $form = $(form).closest('#new-cyclestreets-photo-message')

    $form.find('#image-preview').html(@cyclestreetsPeekImg(feature))
    $form.find("textarea[id$='caption']").changeVal(feature.properties.caption)
    $form.find("input[id$='cyclestreets_id']").changeVal(feature.properties.id)
    $form.find("input[id$='photo_url']").changeVal(feature.properties.thumbnailUrl)
    $form.find("input[id$='icon_properties']").changeVal(JSON.stringify(feature.properties.iconProperties))
    $form.find("input[id$='loc_json']").changeVal(JSON.stringify(feature))

  constructor: (center, opts) ->
    @domId = opts.domid || 'map'
    @map = L.map(@domId, maxZoom: 18)
    @map.attributionControl.setPrefix('').addAttribution(
      """
        <a
          href="#{CONSTANTS.images.mapKey}"
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
        </a>
      """
    ).setPosition('bottomleft')
    @setCenter(center)
    @map.on('baselayerchange', (e) ->
      window.localStorage.setItem('map.baselayer.name', e.name)
    )
    @geoInput = $("##{opts.geoinput}_loc_json")
    @buildCollistionLayer() if opts.collisions?
    @buildPhotoLayer(opts.photoselect) if opts.photos or opts.photoselect
    @remoteJSONLayer = {}
    if opts.remote
      @buildRemoteLayer(remoteLayer) for remoteLayer in opts.remote
    @addLayers(opts)
    @addSearchControl() unless opts.nosearch
    @deletePopup = opts.deletepopup
    if opts.draw?
      @addDraw(opts.feature)
    else if opts.feature?
      @addStaticFeature(opts.feature)
    @map.removeControl(@map.zoomControl) if opts.hidezoom?
    @map.zoomControl.setPosition(opts.zoomposition) if opts.zoomposition
    @drawnFeatures = {}
    @

  featurePointToLayer: (feature, latlng) ->
    return L.marker(latlng) unless feature.properties.thumbnail
    icon = new L.Icon(iconUrl: feature.properties.thumbnail, iconAnchor: feature.properties.anchor)
    L.marker(latlng, {icon: icon})

  addStaticFeature: (collection) ->
    L.geoJson(collection, {
      style: {color: 'black'}, pointToLayer: @featurePointToLayer
    }).addTo @map
    return

  buildRemoteLayer: (opts) ->
    featurePointToLayer = @featurePointToLayer
    @remoteJSONLayer[opts.name] = new L.LayerJSON({
      url: "#{opts.url}?bbox={lon1},{lat1},{lon2},{lat2}"
      propertyItems: 'features'
      propertyLoc: 'geometry.coordinates'
      caching: false
      propertyId: 'id'
      minShift: 10
      dataToMarker: (data)->
        L.geoJson(data,
        pointToLayer: featurePointToLayer
        fillOpacity: 0.1
        fillColor: 'white'
        color: opts.color || '#03f'
        onEachFeature: (feature, layer) ->
          img = if feature.properties.image_url
            "<img src='#{feature.properties.image_url}' width='37' height='37'>"
          created_by = if feature.properties.created_by
           "<p>created by <a href='#{feature.properties.created_by_url}'> #{feature.properties.created_by} </p>"
          layer.bindPopup("#{img || ''} <h3><a href='#{feature.properties.url}'> #{feature.properties.title} </a></h3> #{created_by || ''}")
        )
    }).addTo(@map)

  setCenter: (center) ->
    @map.fitBounds(center.fitBounds) if center.fitBounds?
    @map.setView(center.latLon, center.zoom) if center.latLon
    return

  addLayers: (opts = {}) =>
    @baseLayers = {}
    existingBaseName = window.localStorage.getItem('map.baselayer.name')
    tileServers = $("#map-tiles").data("tileservers")
    if existingBaseName not in (tileServer.name for tileServer in tileServers)
      existingBaseName = null
    for tileServer, idx in tileServers
      continue if (tileServer.url == "" or tileServer.name == "")
      options = jQuery.parseJSON(tileServer.options)
      tileLayer = if tileServer.type == "wms"
        L.tileLayer.wms(tileServer.url, options)
      else
        L.tileLayer(tileServer.url, options)
      @baseLayers[tileServer.name] = tileLayer
      if (existingBaseName == tileServer.name) || (!existingBaseName && idx == 0)
        tileLayer.addTo(@map)

    additionalLayers = @remoteJSONLayer
    additionalLayers['Collisions'] = @collisionLayer if @collisionLayer
    additionalLayers['Photos'] = @photoLayer if @photoLayer

    L.control.layers(@baseLayers, additionalLayers).addTo(@map) unless opts.hidelayers
    @map.addLayer @photoLayer if opts.photoselect

  buildPhotoLayer: (photoselect) =>
    params = [
      {name: 'key', value: $("#map-geocode").data("key") || CONSTANTS.geocoder.apiKey},
      {name: 'fields',
      value: 'id,name,hasPhoto,categoryId,categoryPlural,metacategoryName,iconProperties,thumbnailUrl'},
      {name: 'thumbnailsize', value: 2000},
      {name: 'datetime', value: 'friendly'},
    ]
    $('[data-behaviour="search-cyclestreets"]').click((e) =>
      e.preventDefault()
      $.get(CONSTANTS.geocoder.photoLocationUrl + '?' + $.param(params.concat({name: 'id', value: $('#photo_id_').val()})))
        .done((json) =>
          feature = json.features[0]
          @popUpID = feature.properties.id
          @map.fitBounds(L.geoJson(feature).getBounds())
          window.LeafletMap.updateCyclestreetsPhotoForm(e.target, feature)
        )
    )

    @photoLayer = new L.LayerJSON({
      url: "#{CONSTANTS.geocoder.photoUrl}?#{$.param(params)}&bbox={lon1},{lat1},{lon2},{lat2}"
      propertyItems: 'features'
      propertyLoc: 'geometry.coordinates'
      locAsGeoJSON: true
      propertyId: 'properties.id'
      minShift: 10
      caching: false
      dataToMarker: (feature, latlng) =>
        iconProperties = feature.properties.iconProperties
        iconProperties.iconUrl = CONSTANTS.geocoder.cyclestreetsUrl + iconProperties.iconUrl
        iconProperties.shadowUrl = CONSTANTS.geocoder.cyclestreetsUrl + iconProperties.shadowUrl
        icon = new L.Icon(iconProperties)
        marker = new L.marker(latlng, {icon: icon})
        # Declarations
        id = feature.properties.id
        latitude = feature.geometry.coordinates[1]
        longitude = feature.geometry.coordinates[0]
        # Get caption
        caption = "<p class=\"caption\">#{feature.properties.caption}</p>"
        # Headline
        headline = '<p></p>'
        if feature.properties.hasOwnProperty('categoryPlural') and feature.properties.hasOwnProperty('metacategoryName')
          headline += "<p class=\"categorisationnote small\">Categorisation: #{feature.properties.categoryPlural} (#{feature.properties.metacategoryName.toLowerCase()})</p>"
        # The main bit of the content
        mainContent = '<p class="peekimage">' + @constructor.cyclestreetsPeekImg(feature) + '</p>'
        selectable = if photoselect
          "<div class='formtastic btn-green' id='cs-image-#{feature.properties.id}'> #{CONSTANTS.i18n.selectImage} </button>"
        else
          ""

        popup = marker.bindPopup('<div class="photo bubble">' + headline + mainContent + caption + selectable + '</div>').on("click", ->
          $("#cs-image-#{feature.properties.id}").click (e)->
            window.LeafletMap.updateCyclestreetsPhotoForm(e.target, feature)
        )
        popup.openPopup() if @popUpID == id

        return marker
    })

    # https://github.com/stefanocudini/leaflet-layerJSON/issues/19
    oldOnRemove = @photoLayer.onRemove.bind(@photoLayer)
    @photoLayer.onRemove = (map)->
      oldOnRemove(map)
      @._markersCache = {}

  buildCollistionLayer: =>
    lookup = {
      fatal: { color: '#aa0000', fillColor: '#ff0000', radius: 10 },
      serious: { color: '#e44500', fillColor: '#ff8814', radius: 8 },
      slight: { color: '#a7932f', fillColor: '#fcff00', radius: 6 }
    }
    params = [
      {name: 'key', value: $("#map-geocode").data("key") || CONSTANTS.geocoder.apiKey}
      {name: 'fields', value: 'id,latitude,longitude,datetime,severity,url'},
      {name: 'datetime', value: 'friendly'},
    ]
    @collisionLayer = new L.LayerJSON({
      url: "#{CONSTANTS.geocoder.collisionsUrl}?#{$.param(params)}&bbox={lon1},{lat1},{lon2},{lat2}"
      propertyItems: 'features'
      propertyLoc: ['properties.latitude','properties.longitude']
      minShift: 10
      caching: false
      propertyId: 'properties.id'
      dataToMarker: (feature, latlng) =>
        props = lookup[feature.properties.severity]
        marker = new L.CircleMarker(latlng, props)
        marker.bindPopup(
          "<h3><a href=\"#{feature.properties.url}\">Collision #{feature.properties.id}</a></h3>
          <p>Date and time: #{feature.properties.datetime} </p>
          <p>Severity: #{feature.properties.severity} </p>
          <p><a href=\"#{feature.properties.url}\">View on CycleStreets</a></p>"
        )
        return marker
    })

    # https://github.com/stefanocudini/leaflet-layerJSON/issues/19
    oldOnRemove = @collisionLayer.onRemove.bind(@collisionLayer)
    @collisionLayer.onRemove = (map)->
      oldOnRemove(map)
      @._markersCache = {}

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
        {name: 'key', value: $("#map-geocode").data("key") || CONSTANTS.geocoder.apiKey}
        {name: 'bbox', value: bbox}
      ]

      $.ajax(
        url: $("#map-geocode").data("url") || CONSTANTS.geocoder.geoUrl
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
      @drawnItems.removeLayer @drawnFeatures[id]
      @drawnLayerChanged()
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
    @drawnItems.addLayer layer
    if @deletePopup
      domelem = document.createElement('a')
      domelem.innerHTML = "#{CONSTANTS.i18n.delete}?</a>"
      domelem.onclick = =>
        @drawnItems.removeLayer layer
        @drawnLayerChanged()
      @drawnItems.bindPopup(domelem)
    @drawnLayerChanged()

  drawnLayerChanged: =>
    @geoInput.changeVal JSON.stringify(@drawnItems.toGeoJSON())
    $("a[title='Save changes.']")[0].click() if @_editing
    $('.leaflet-draw-edit-edit')[0].click()

  addDraw: (feature) =>
    layer.setOpacity(0.7) for _, layer of @baseLayers

    @drawnItems = new L.FeatureGroup()
    $('.icon-save').toggle()

    @map.addLayer @drawnItems
    drawControl = new L.Control.Draw {
      position: 'topright'
      edit: {
        featureGroup: @drawnItems
        edit: { selectedPathOptions: { fillColor: '#00008B', maintainColor: true } }
      }
      draw: {
        circle: false
        rectangle: false
        polygon: {
          shapeOptions: { color: '#00008B', opacity: 0.75 }
        }
        polyline: {
          shapeOptions: { color: '#00008B', opacity: 0.75 }
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
      @drawFeature(layer) for layer in @drawnItems.getLayers()

    if feature
      @drawFeature(layer) for layer in L.geoJson(feature).getLayers()
    else
      # enable point / marker draw as standard
      $(".leaflet-draw-draw-marker")[0].click()
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

    $useGroupLocation = $("#use-group-location")
    $useGroupLocation.click (evt) =>
      evt.preventDefault()
      evt.stopPropagation()
      @drawnItems.clearLayers()
      groupLocation = $useGroupLocation.data("location")
      @geoInput.changeVal(groupLocation)
      geoJson = L.geoJson(groupLocation)
      @drawFeature(layer) for layer in geoJson.getLayers()
      @map.fitBounds(geoJson.getBounds())

    # Otherwise clear wipes any shapes on the map
    $('.edit-clear').click (evt) =>
      evt.preventDefault()
      evt.stopPropagation()
      @drawnItems.clearLayers()
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
    $('.edit-undo').click (evt) ->
      evt.preventDefault()
      evt.stopPropagation()
      if @drawnItems.getLayers().slice(-1)[0]?.editing?._enabled
        @drawnItems.removeLayer(@drawnItems.getLayers()[-1..][0])
      else
        $('ul.leaflet-draw-actions a[title^="Delete"]')[0].click()

window.leafletMapInit = ->
  for mapData in $('.map-data')
    domMap = $(mapData)
    new LeafletMap(domMap.data('center'), domMap.data('opts')) unless domMap.data('skip')
    domMap.data("skip", true)

jQuery ->
  window.leafletMapInit()
