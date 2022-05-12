$(document).ready(function () {
  var $votes = $('.votes')
  var $oneVote = $($votes[0])
  var voteIds = $votes.map(function () {
    return $(this).data('id')
  })
  if ($oneVote) {
    $.post({
      url: $($oneVote).data('url'),
      data: {ids: $.makeArray(voteIds)}
    })
  }
})
