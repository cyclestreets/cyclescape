$(window).on('load', function () {
  var lastViewed = document.querySelector('[data-last-viewed]')
  if (lastViewed) {
    lastViewed.scrollIntoView()
    var options = {
      rootMargin: '-65px 0px 0px 0px',
      threshold: 1.0
    }
    var obs = new IntersectionObserver(function (entries) {
      if (document.querySelector('[data-last-viewed]') && entries[0] && entries[0].isIntersecting) {
        $.ajax({url: window.location.pathname, data: {lastViewed: document.querySelector('[data-last-viewed]').dataset.lastViewed}, dataType: 'script'})
      }
    }, options)
    obs.observe(lastViewed)
  }
})
