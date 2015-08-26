window.mapInit = ->
  return if !google? || !google.maps.LatLng
  issue = new (google.maps.LatLng)(svLongNew, svLatNew)
  svs = new google.maps.StreetViewService()
  panorama = null
  map = null

  processSVData =  (data, status) ->
    if (status == google.maps.StreetViewStatus.OK)
      mapOptions = {
        center: data.location.latLng,
        zoom: 15
      }
      map = new google.maps.Map(
        document.getElementById('newStreetViewMap'), mapOptions)

      panorama.setPosition(data.location.latLng)
      panorama.setPov({
        heading: 270,
        pitch: 0
      })
      updateLocation()
      updatePov()
      map.setStreetView(panorama)
      panorama.setVisible(true)
    else
      pano = $("#newStreetViewPano").text('')
      warningList = $('<ul>').addClass('bullets')
      warningList.append $('<li>').text('Within 200m of the issue no Street View has been found')
      pano.prepend warningList
      pano.prepend $('<br>')
    return

  updateLocation = ->
    $("#street_view_message_location_string").val panorama.getPosition()
    return
  updatePov = ->
    $("#street_view_message_heading").val panorama.getPov().heading
    $("#street_view_message_pitch").val panorama.getPov().pitch
    return

  addStreetView = (sv) ->
    issue = new (google.maps.LatLng)(sv.long, sv.lat)

    panoramaOptions = {
      position: issue,
      linksControl: false,
      panControl: false,
      pov: {
        heading: sv.head,
        pitch: sv.pitch
      },
      visible: true
    }
    new google.maps.StreetViewPanorama(document.getElementById("streetViewPano#{sv.id}"), panoramaOptions)
    return

  initialize = ->
    panorama = new google.maps.StreetViewPanorama(document.getElementById("newStreetViewPano"))

    svs.getPanoramaByLocation(issue, 200, processSVData)

    google.maps.event.addListener panorama, 'position_changed', ->
      updateLocation()
    google.maps.event.addListener panorama, 'pov_changed', ->
      updatePov()

    # http://stackoverflow.com/questions/14861975/resize-google-maps-when-tabs-are-triggered
    $("a[href$='#new-street-view-message']").click (e)->
      google.maps.event.trigger(panorama, 'resize')
      google.maps.event.trigger(map, 'resize')

    addStreetView(streetView) for streetView in streetViews

    return
  initialize()

$(document).ready(window.mapInit)
