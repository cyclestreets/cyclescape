$ ->
  # Modal overlay links
  $("a[rel='#overlay']")
    .overlay
      onBeforeLoad: ->
        # Load the page given in the link HREF
        wrapper = this.getOverlay().find(".wrapper")
        $.ajax this.getTrigger().attr("href"),
          success: (data, status, xhr) =>
            wrapper.html(data)
            # Have to bind close link manually as it doesn't
            # seem to work with AJAX loading
            wrapper.find(".cancel a, .close").click =>
              this.close()
              false
          error: (xhr, status, error) =>
            # Basic error display
            wrapper.html(xhr.responseText)
      mask:
        color: "black"
        opacity: 0.6

  $("#overlay form[data-remote]")
    .live "ajax:success", (e, data, status, xhr) ->
      $(this).parents(".wrapper:first").html(data)
    .live "ajax:error", (e, xhr, status, error) ->
      $(this).parents(".wrapper:first").html(xhr.responseText)
