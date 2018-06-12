class ImageEdit {
  constructor (opts) {
    opts = opts || {}

    this.fileEl = $(opts.fileEl || '#picture-file')
    this.previewEl = $(opts.previewEl || '#picture-preview')
    this.base64El = $(opts.base64El || '#picture-base64')
    this.croppieInstance = this.previewEl.croppie({
      boundary: {
        width: (opts.width || 330) + 100,
        height: (opts.height || 192) + 100
      },
      viewport: {
        width: opts.width || 330,
        height: opts.height || 192
      },
      enableExif: true
    })
  }

  readFile (input, imageEdit) {
    if (input.files && input.files[0]) {
      var reader = new FileReader()

      reader.onload = function (e) {
        imageEdit.previewEl.addClass('ready')
        imageEdit.croppieInstance.croppie('bind', {
          url: e.target.result
        })
      }

      reader.readAsDataURL(input.files[0])
    }
  }

  initFileOnChange () {
    var imageEdit = this
    this.readFile(this.fileEl, imageEdit)
    this.fileEl.on('change', function () { imageEdit.readFile(this, imageEdit) })
  }

  initCroppieOnChange () {
    var base64El = this.base64El
    this.croppieInstance.on('update.croppie', function () {
      $(this).croppie('result', 'base64').then(
        function (base64) {
          base64El.val(base64)
        }
      )
    })
  }
}
