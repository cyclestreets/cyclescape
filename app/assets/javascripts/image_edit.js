class ImageEdit {
  constructor (opts) {
    var attribute = opts.attribute || 'picture'

    this.fileEl = $('#file_' + attribute)
    this.previewEl = $('#preview_' + attribute)
    this.rotateEl = $('#rotate_' + attribute)
    this.base64El = $('#' + opts.resource + '_base64_' + attribute)
    this.croppieInstance = this.previewEl.croppie({
      boundary: {
        width: (opts.width || 330) + 100,
        height: (opts.height || 192) + 100
      },
      viewport: {
        width: opts.width || 330,
        height: opts.height || 192
      },
      enableExif: true,
      enableOrientation: true,
      url: opts.url
    })
    this.readFile = this.readFile.bind(this)
    this.initFileOnChange = this.initFileOnChange.bind(this)
    this.initCroppieOnChange = this.initCroppieOnChange.bind(this)
    this.updateResult = this.updateResult.bind(this)
  }

  readFile (input) {
    if (input.files && input.files[0]) {
      var reader = new FileReader()

      reader.onload = function (e) {
        this.previewEl.addClass('ready')
        this.croppieInstance.croppie('bind', {
          url: e.target.result
        })
      }.bind(this)

      reader.readAsDataURL(input.files[0])
    }
  }

  initFileOnChange () {
    var imageEdit = this
    this.readFile(this.fileEl[0])
    this.fileEl.on('change', function () { imageEdit.readFile(this) })
    this.rotateEl.on('click', function () {
      imageEdit.croppieInstance.croppie('rotate', -90)
      this.updateResult()
    }.bind(this))
  }

  initCroppieOnChange () {
    this.croppieInstance.on('update.croppie', this.updateResult)
  }

  updateResult () {
    this.croppieInstance.croppie('result', 'base64').then(
      function (base64) {
        this.base64El.val(base64)
      }.bind(this)
    )
  }
}
