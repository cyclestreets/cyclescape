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

document.addEventListener('turbo:load', () => {
  const scrollTo = new URLSearchParams(window.location.search).get('st')
  if (scrollTo) {
    const element = document.getElementById(scrollTo)
    if (element) element.scrollIntoView()
  }
})
