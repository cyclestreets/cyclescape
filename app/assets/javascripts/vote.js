$(document).ready(function () {
  var $votes = $('.votes')

  var voteIds = $votes.map(function () {
    return $(this).data('id')
  })
  if ($votes[0]) {
    $.post({
      url: $($votes[0]).data('url'),
      data: {ids: $.makeArray(voteIds)}
    })
  }
})
