$(document).ready(function () {
  var lastViewedMessage
  var lastViewedMessageID = $('[data-view-message-id]').data('view-message-id')
  var messageWantedID = window.location.hash.substr(1)
  var messageWanted = messageWantedID && messageWantedID.indexOf("message_") === 0
  var messageWantedEl
  var getMessages = function() {
    return $.ajax(
      {
        url: window.location.pathname,
        data: {initiallyLoadedFrom: document.querySelector('[data-initially-loaded-from]').dataset.initiallyLoadedFrom},
        dataType: 'script'
      }
    )
  }
  if (lastViewedMessageID) {
    lastViewedMessage = document.getElementById('message_' + lastViewedMessageID)
    lastViewedMessage && lastViewedMessage.scrollIntoView()
  }

  var loadMoreObserver = function() {
    var initiallyLoadedFrom = document.querySelector('[data-initially-loaded-from]')
    if (initiallyLoadedFrom) {
      var options = {
        rootMargin: '1500px 0px 0px 0px',
        threshold: 0
      }
      var obs = new IntersectionObserver(function (entries) {
        if (entries[0] && entries[0].isIntersecting) {
          obs.unobserve(initiallyLoadedFrom)
          getMessages().then(function() {
            initiallyLoadedFrom = document.querySelector('[data-initially-loaded-from]')
            if (initiallyLoadedFrom) {
              obs.observe(initiallyLoadedFrom)
            }
          })
        }
      }, options)
      obs.observe(initiallyLoadedFrom)
    }
  }

  if(messageWanted){
    var scrollToMessageWanted = function() {
      messageWantedEl = document.getElementById(messageWantedID)
      if(messageWantedEl) {
        messageWantedEl.scrollIntoView()
        loadMoreObserver()
        return
      }
      if (!document.querySelector('[data-initially-loaded-from]')) {
        return
      }
      getMessages().then(scrollToMessageWanted)
    }
    scrollToMessageWanted()
  } else {
    loadMoreObserver()
  }
})
