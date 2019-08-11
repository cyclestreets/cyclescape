$(document).ready(function () {
  var offset
  var viewMessageId = $('#content').data().viewMessageId
  if (viewMessageId) {
    offset = $('#message-' + viewMessageId).offset()
  }
  if (!window.location.hash && offset) {
    $('html, body').animate({
      scrollTop: offset.top - 77
    }, 350, 'swing')
  }
})
