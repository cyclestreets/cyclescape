$(document).ready ->
  issue = new (google.maps.LatLng)(svLong, svLat)
  sv = new google.maps.StreetViewService()
  panorama = null

  processSVData =  (data, status) ->
    if (status == google.maps.StreetViewStatus.OK)
      panorama.setPano(data.location.pano)
      panorama.setPov({
        heading: 270,
        pitch: 0
      })
      updateLocation()
      updatePov()

      panorama.setVisible(true)
    else
      pano = $("#pano").text('')
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

  initialize = ->
    panorama = new google.maps.StreetViewPanorama(document.getElementById("streetViewPano"))

    sv.getPanoramaByLocation(issue, 200, processSVData)

    google.maps.event.addListener panorama, 'position_changed', ->
      updateLocation()
    google.maps.event.addListener panorama, 'pov_changed', ->
      updatePov()

    return

  google.maps.event.addDomListener window, 'load', initialize
