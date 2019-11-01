// This is called when:
//   1. The page is ready
//   2. The Google StreetView JS is loaded
//   3. A message is created (via Ajax)
// Because loading external JS from Google could be faster than the page load (if it is cached) or slower (network)
// there are a few early returns.
window.streetViewInit = function () {
  if ((typeof window.google === 'undefined' || window.google === null) || !window.google.maps.LatLng) {
    return
  }
  var addStreetView, map, processSVData, svs
  svs = new window.google.maps.StreetViewService()
  processSVData = function (panorama) {
    return function (data, status) {
      var mapOptions, pano, warningList
      if (status === window.google.maps.StreetViewStatus.OK) {
        mapOptions = {
          center: data.location.latLng,
          zoom: 15
        }
        map = new window.google.maps.Map(document.getElementById('newStreetViewMap'), mapOptions)
        panorama.setPosition(data.location.latLng)
        panorama.setPov({
          heading: 270,
          pitch: 0
        })
        map.setStreetView(panorama)
        panorama.setVisible(true)
      } else {
        pano = $('#newStreetViewPano').text('')
        warningList = $('<ul>').addClass('bullets')
        warningList.append($('<li>').text('Within 200m of the issue no Street View has been found'))
        pano.prepend(warningList)
        pano.prepend($('<br>'))
      }
    }
  }
  addStreetView = function (el) {
    var dataAtt, issue, panoramaOptions, sv
    sv = el.dataset
    dataAtt = 'data-street-view-initialized'
    if (el.hasAttribute(dataAtt)) {
      return
    }
    issue = new window.google.maps.LatLng(sv.long, sv.lat)
    panoramaOptions = {
      position: issue,
      linksControl: false,
      panControl: false,
      pov: {
        heading: parseInt(sv.heading),
        pitch: parseInt(sv.pitch)
      },
      visible: true
    }
    new window.google.maps.StreetViewPanorama(el, panoramaOptions) // eslint-disable-line no-new
    el.setAttribute(dataAtt, 1)
  }

  var captionInput, headingInput, issue, locationInput, newStreetViewPano, panorama, pitchInput, subForm, updateInputReady, updateInputs, svLongNew, svLatNew
  $('.google-street-view').each(function (_, streetView) { addStreetView(streetView) })
  newStreetViewPano = document.getElementById('newStreetViewPano')
  subForm = document.getElementById('new-street-view-message')
  if (!newStreetViewPano || !subForm) {
    return
  }
  svLongNew = newStreetViewPano.dataset.long
  svLatNew = newStreetViewPano.dataset.lat
  if (!svLongNew) {
    return
  }
  locationInput = subForm.querySelector("input[id$='location_string']")
  headingInput = subForm.querySelector("input[id$='heading']")
  pitchInput = subForm.querySelector("input[id$='pitch']")
  captionInput = subForm.querySelector("[id$='caption']")
  panorama = new window.google.maps.StreetViewPanorama(newStreetViewPano)
  $('#newStreetViewPano, #newStreetViewMap').click(function () {
    updateInputReady = true
  })
  updateInputs = function () {
    if (!updateInputReady) {
      return
    }
    locationInput.value = panorama.getPosition().toString()
    headingInput.value = panorama.getPov().heading
    pitchInput.value = panorama.getPov().pitch
  }
  issue = new window.google.maps.LatLng(svLongNew, svLatNew)
  svs.getPanoramaByLocation(issue, 200, processSVData(panorama))
  window.google.maps.event.addListener(panorama, 'position_changed', function () {
    updateInputs()
  })
  window.google.maps.event.addListener(panorama, 'pov_changed', function () {
    updateInputs()
  })
  $("a[href$='#new-street-view-message']").click(function (e) {
    window.google.maps.event.trigger(panorama, 'resize')
    window.google.maps.event.trigger(map, 'resize')
  })
  captionInput.addEventListener('change', function () {
    updateInputReady = true
    updateInputs()
  })
}

$(document).ready(window.streetViewInit)
