$(document).ready(function () {
  var $votes = $('.votes')
  var $oneVote = $($votes[0])
  var voteIds = $votes.map(function () {
    return $(this).data('id')
  })
  if ($oneVote.data('url') && !$oneVote.find('.access-denied')[0]) {
    $.get({
      url: $($votes[0]).data('url'),
      data: {ids: $.makeArray(voteIds)}
    })
  }
})
