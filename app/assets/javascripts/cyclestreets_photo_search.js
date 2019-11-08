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
        var feature = json.features[0]
        var thumbnailUrl = feature.properties.thumbnailUrl
        var peekImgEl = '<img class="no-float" src="' + thumbnailUrl + '" alt="Image loading &hellip;"/>'

        var form = $(e.target).closest('#new-cyclestreets-photo-message')

        form.find('#image-preview').html(peekImgEl)

        form.find("textarea[id$='caption']").changeVal(feature.properties.caption)
        form.find("input[id$='cyclestreets_id']").changeVal(feature.properties.id)
        form.find("input[id$='photo_url']").changeVal(thumbnailUrl)
        form.find("input[id$='icon_properties']").changeVal(JSON.stringify(feature.properties.iconProperties))
        form.find("input[id$='loc_json']").changeVal(JSON.stringify(feature))
      })
  })
})
