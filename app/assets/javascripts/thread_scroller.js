$(document).ready(function () {
  var viewMessageId = $('[data-view-message-id]').data('view-message-id')
  if (viewMessageId) {
    document.getElementById('message_' + viewMessageId).scrollIntoView(true)
  }
})
