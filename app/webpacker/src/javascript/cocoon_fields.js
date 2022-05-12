$(function () {
  var domId = '#poll-options'
  // controlls the limits the of poll options
  $(domId).on('cocoon:after-insert', function () {
    checkToHideOrShowAddLink()
  })

  $(domId).on('cocoon:after-remove', function () {
    checkToHideOrShowAddLink()
  })

  checkToHideOrShowAddLink()

  function checkToHideOrShowAddLink () {
    if ($(domId + ' .nested-fields').length <= 2) {
      $(domId + ' a.remove_fields').hide()
    } else {
      $(domId + ' a.remove_fields').show()
    }

    if ($(domId + ' .nested-fields').length >= 10) {
      $(domId + ' a.add_fields').hide()
    } else {
      $(domId + ' a.add_fields').show()
    }
  }
})
