$(window).on('load', function () {
  var offset
  var viewMessageId = $('[data-view-message-id]').data('view-message-id')
  if (viewMessageId) {
    offset = $('#message_' + viewMessageId).offset()
  }
  if (!window.location.hash && offset) {
    $('html, body').animate({
      scrollTop: offset.top - 77
    }, 350, 'swing')
  }
})
