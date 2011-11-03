jQuery ->
  $(".clickable").live "click", (e) ->
    window.location.href = $(this).find("a.primary-link").attr("href")

  $(".collapsible")
    .hover ->
      $(this).find(".collapse").slideDown()
    , ->
      $(this).find(".collapse").slideUp()
    .find(".collapse").hide()
