function ImageEdit (opts) {
  var attribute = opts.attribute || 'picture'

  this.opts = opts
  this.fileEl = $('#file_' + attribute)
  this.previewEl = $('#preview_' + attribute).attr('src', opts.url)
  this.rotateEl = $('#rotate_' + attribute)
  this.zoomInEl = $('#zoom_in_' + attribute)
  this.zoomOutEl = $('#zoom_out_' + attribute)
  this.base64El = $('#' + opts.base64el + '_base64_' + attribute)
  this.readFile = this.readFile.bind(this)
  this.initFileOnChange = this.initFileOnChange.bind(this)
  this.initCroppie = this.initCroppie.bind(this)
  this.updateResult = this.updateResult.bind(this)
}

ImageEdit.prototype.readFile = function (input) {
  if (input.files && input.files[0]) {
    var file = input.files[0]
    var reader = new FileReader()
    this.fileType = file.type

    reader.onload = function (_) {
      this.previewEl[0].src = reader.result
      this.initCroppie()
    }.bind(this)

    reader.readAsDataURL(file)
  }
}

ImageEdit.prototype.initFileOnChange = function () {
  var imageEdit = this
  this.readFile(this.fileEl[0])
  this.fileEl.on('change', function () {
    imageEdit.previewEl.attr('src', null)
    imageEdit.readFile(this)
    if (imageEdit.cropper) {
      imageEdit.cropper.destroy()
    }
  })
}

ImageEdit.prototype.initCroppie = function () {
  if (!this.previewEl[0].src) {
    return
  }
  this.cropper = new Cropper(this.previewEl[0], {
    zoomable: !!this.opts.showzoomer,
    autoCrop: false,
    autoCropArea: 1,
    aspectRatio: this.opts.enableresize ? NaN : this.opts.width / this.opts.height,
    ready: function () {
      var canvas = this.cropper.initialCanvasData
      this.cropper.zoomTo(
        canvas.width / (canvas.naturalWidth), {
          x: canvas.width / 2,
          y: canvas.height / 2
        }
      ).crop()
      this.updateResult()
    }.bind(this)
  })
  this.previewEl[0].addEventListener('cropend', this.updateResult)
  this.previewEl[0].addEventListener('zoom', this.updateResult)
  this.rotateEl.parent().on('click', function () {
    this.cropper.rotate(-90)
    this.updateResult()
  }.bind(this))
  this.zoomInEl.parent().on('click', function () {
    this.cropper.zoom(0.1)
  }.bind(this))
  this.zoomOutEl.parent().on('click', function () {
    this.cropper.zoom(-0.1)
  }.bind(this))
}

ImageEdit.prototype.updateResult = function () {
  var canvas = this.cropper.getCroppedCanvas()
  if (canvas) {
    this.base64El.val(canvas.toDataURL(this.fileType))
  }
}
window.initImageEdit = function () {
  $('.image-edit-upload').each(function (_, upload) {
    if (upload.dataset.imageeditinit === '1') {
      return
    }
    var imageEdit = new ImageEdit($(upload).data('imageedit'))
    imageEdit.initFileOnChange()
    imageEdit.initCroppie()
    upload.dataset.imageeditinit = '1'
  })
}

$(document).ready(window.initImageEdit)
