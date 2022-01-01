$(document).ready(function () {
  var lastViewedMessage
  var lastViewedMessageId = $('[data-view-message-id]').data('view-message-id')
  if (lastViewedMessageId) {
    lastViewedMessage = document.getElementById('message_' + lastViewedMessageId)
    lastViewedMessage && lastViewedMessage.scrollIntoView()
  }
  var initiallyLoadedFrom = document.querySelector('[data-initially-loaded-from]')
  if (initiallyLoadedFrom && lastViewedMessage) {
    var options = {
      rootMargin: '-300px 0px 0px 0px',
      threshold: 1.0
    }
    var obs = new IntersectionObserver(function (entries) {
      if (lastViewedMessage && entries[0] && entries[0].isIntersecting) {
        $.ajax({url: window.location.pathname, data: {initiallyLoadedFrom: initiallyLoadedFrom.dataset.initiallyLoadedFrom}, dataType: 'script'})
        obs.unobserve(lastViewedMessage)
      }
    }, options)
    obs.observe(lastViewedMessage)
  }
})
