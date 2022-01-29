$(document).ready(function () {
  var lastViewedMessage
  var lastViewedMessageId = $('[data-view-message-id]').data('view-message-id')
  if (lastViewedMessageId) {
    lastViewedMessage = document.getElementById('message_' + lastViewedMessageId)
    lastViewedMessage && lastViewedMessage.scrollIntoView()
  }
  var initiallyLoadedFrom = document.querySelector('[data-initially-loaded-from]')
  if (initiallyLoadedFrom) {
    var options = {
      rootMargin: '1500px 0px 0px 0px',
      threshold: 0
    }
    var obs = new IntersectionObserver(function (entries) {
      if (entries[0] && entries[0].isIntersecting) {
        obs.unobserve(initiallyLoadedFrom)
        $.ajax(
          {
            url: window.location.pathname,
            data: {initiallyLoadedFrom: document.querySelector('[data-initially-loaded-from]').dataset.initiallyLoadedFrom},
            dataType: 'script'
          }
        ).then(function() {
          initiallyLoadedFrom = document.querySelector('[data-initially-loaded-from]')
          if (initiallyLoadedFrom) {
            obs.observe(initiallyLoadedFrom)
          }
        })
      }
    }, options)
    obs.observe(initiallyLoadedFrom)
  }
})
