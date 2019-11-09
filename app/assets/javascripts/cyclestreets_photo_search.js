$(document).ready(function () {
  var params = [
    {name: 'key', value: $('#map-geocode').data('key') || CONSTANTS.geocoder.apiKey},
    {name: 'fields',
      value: 'id,name,hasPhoto,categoryId,categoryPlural,metacategoryName,iconProperties,thumbnailUrl'},
    {name: 'thumbnailsize', value: 2000},
    {name: 'datetime', value: 'friendly'}
  ]
  $('[data-behaviour="search-cyclestreets"]').click(function (e) {
    e.preventDefault()
    $.get(CONSTANTS.geocoder.photoLocationUrl + '?' + $.param(params.concat({name: 'id', value: $('#photo_id_').val()})))
      .done(function (json) {
        window.LeafletMap.updateCyclestreetsPhotoForm(e.target, json.features[0])
      })
  })
})
