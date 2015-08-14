jQuery ->
  # Tabs
  $("ul.tabs").tabs("> div.panes > div")
  $("ul.tabs.with-history").tabs("> div.panes > div", { history: true })

  # Scrollables
  $("div.scrollable.autoheight")
    .bind "update_height", (e, index) ->
        # Update the height of the container to match the contents
        scroller = $(this).data("scrollable")
        index = scroller.getIndex() unless index
        current_panel = $(scroller.getItems()[index])
        wrapper = scroller.getRoot()
        wrapper.animate({height: current_panel.outerHeight()}, 200)
    .scrollable
      onBeforeSeek: (e, index) ->
        this.getRoot().trigger "update_height", [index]

  # Crude way to make large blocks .clickable by definiting a.primary-link in them
  $(".clickable").live "click", (e) ->
    window.location.href = $(this).find("a.primary-link").attr("href")

  # When .collapsible item is hovered in/out the .collapse elements inside
  # expand and collapse
  $(".collapsible")
    .hover ->
      $(this).find(".collapse").slideDown()
    , ->
      $(this).find(".collapse").slideUp()
    .find(".collapse").hide()

  # Apply date selector to all date inputs
  $(":input.date").dateinput
    format: "dddd, dd mmmm yyyy"

  # Automatic setting of values and visibility from select drop-downs
  AutoSet = {
    selector: "select"

    trigger_all: (source_select) ->
      this.update_options(source_select)
      this.update_value(source_select)
      this.update_visibility(source_select)

    # When a select box is changed search for other selects that
    # are linked via the auto-options and auto-options-param data
    # attributes and update the target select box with the new options.
    update_options: (source_select) ->
      $("select[data-auto-options='##{source_select.attr("id")}']").each ->
        target_select = $ this
        param = target_select.data("auto-options-param")
        new_options = source_select.find("option:selected").data(param)
        target_select.empty().addOption(new_options, false)

    # When a select box is changed search for other selects that
    # are linked via the autoset and autoset-param data attributes
    # and update them with the new value.
    update_value: (source_select) ->
      $("select[data-autoset='##{source_select.attr("id")}']").each ->
        target_select = $ this
        param = target_select.data("autoset-param")
        new_value = source_select.find("option:selected").data(param)
        target_select.val(new_value)

    # When a select box is changed find any dependent elements and
    # hide or show based on whether the new value is blank or not.
    update_visibility: (source_select) ->
      $("*[data-dependent='##{source_select.attr("id")}']").each ->
        target = $ this
        if source_select.val() != ""
          target.show()
        else
          target.hide()
  }

  $(document).on "change", AutoSet.selector, ->
    AutoSet.trigger_all($(this))

  $(document).on "ajaxSuccess", (e) ->
    $(AutoSet.selector).each ->
      AutoSet.trigger_all($(this))

  # Modal overlay links
  $("a[rel='#overlay']")
    .overlay
      onBeforeLoad: ->
        # Load the page given in the link HREF
        wrapper = this.getOverlay().find(".inner")
        $.ajax this.getTrigger().attr("href"),
          success: (data, status, xhr) =>
            wrapper.append($('<div/>').append(data).find('#page'))
            # Hide loading spinner
            wrapper.siblings(".loading").hide()
            # Have to bind close link manually as it doesn't
            # seem to work with AJAX loading
            wrapper.on "click", ".cancel a, .close", =>
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
      $(this).parents(".inner:first").html(data)
    .live "ajax:error", (e, xhr, status, error) ->
      $(this).parents(".inner:first").html(xhr.responseText)

  $("a.dialog").overlay
    mask:
      color: "#000000"
      opacity: 0.6

  # Tools menu
  $(document)
    .on "click", "menu.tools", ->
      $(this).toggleClass("reveal")
    .on "touchend", "menu.tools", ->
      $(this).addClass("reveal")
    .on "mouseleave", "menu.tools", ->
      $(this).removeClass("reveal")

  $("div.group-selector").on "click", (e) ->
    $(this).toggleClass "open closed"

  # Autosize text areas, but only with the right CSS class
  $("textarea.autosize").autosize();
