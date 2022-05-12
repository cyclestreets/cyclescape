$(document).ready(function () {
  // This gets the ajax request, appends the file data.
  // Sadly the contentType is not set correctly when altered in a beforeSend callback
  // so instead we create a new ajax request and cancle the old one by returning false.
  $('#document_message_form').on('ajax:beforeSend', function (_, xhr, settings) {
    if (settings.data.constructor === FormData) {
      return true
    }
    var formData = new FormData()
    var fileEl = $('#document_message_file')[0]
    var file = (fileEl.files || [])[0]
    settings.data.split('&').reduce(function (params, param) {
      var paramSplit = param.split('=').map(function (value) {
        return decodeURIComponent(value.replace(/\+/g, ' '))
      })
      formData.append(paramSplit[0], paramSplit[1])
    }, {})
    formData.append('document_message[file]', file, (file || {}).name)
    settings.data = formData
    settings.contentType = false
    settings.processData = false
    $.post(settings)

    return false
  })
})
