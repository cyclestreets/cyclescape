$ ->
  $("a[rel='#overlay']")
    .overlay
      onBeforeLoad: ->
        wrapper = this.getOverlay().find(".wrapper")
        wrapper.load this.getTrigger().attr("href"),
          =>
            # Have to bind close link manually as it doesn't
            # seem to work with AJAX loading
            wrapper.find(".cancel a").click =>
              this.close()
              false
      mask:
        color: "#ebecff"
        opacity: 0.9

  $("#overlay form[data-remote]")
    .live "ajax:success", (e, data, status, xhr) ->
      $(this).parents(".wrapper:first").html(data)
