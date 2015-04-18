$(document).ready ->
  initialize = ->
    issue = new (google.maps.LatLng)(svLong, svLat)

    panoramaOptions = {
      position: issue,
      pov: {
        heading: svHead,
        pitch: svPitch
      },
      visible: true
    }
    panorama = new google.maps.StreetViewPanorama(document.getElementById("streetViewPano"), panoramaOptions)
    return

  google.maps.event.addDomListener window, 'load', initialize
