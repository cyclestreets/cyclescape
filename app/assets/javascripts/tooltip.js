addEventListener('turbo:before-stream-render', (event) => {
  const fallbackToDefaultActions = event.detail.render

  event.detail.render = function (streamElement) {
    fallbackToDefaultActions(streamElement)
    var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
    popoverTriggerList.map(function (popoverTriggerEl) {
      return new bootstrap.Popover(popoverTriggerEl)
    })
  }
})
})
