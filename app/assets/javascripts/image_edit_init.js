$(document).ready(function () {
  $('.image-edit-upload').each(function (_, upload) {
    var imageEdit = new ImageEdit($(upload).data('imageedit'))
    imageEdit.initFileOnChange()
    imageEdit.initCroppieOnChange()
  })
})
