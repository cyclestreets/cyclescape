jQuery ->
  # Tabs
  $(".tabs").parent().tabs()

  # Crude way to make large blocks .clickable by definiting a.primary-link in them
  $(".clickable").click ->
    window.location.href = $(this).find("a.primary-link").attr("href")

  # When .collapsible item is hovered in/out the .collapse elements inside
  # expand and collapse
  $(".collapsible")
    .hover ->
      $(this).find(".collapse").slideDown()
    , ->
      $(this).find(".collapse").slideUp()
    .find(".collapse").hide()

  dateTimeOpts = {
    dateFormat: "dd-mm-yy"
    stepMinute: 15
    showButtonPanel: false
    minDateTime: new Date((new(Date)).setMinutes(0))
  }

  # Apply date selector to all date inputs
  $(":input.date").datetimepicker( dateTimeOpts )

  $(".all-day:input").change ->

    dateTimeOpts.showTimepicker =  !$(@).is(':checked')
    dateTimeOpts.timeFormat = if($(@).is(':checked')) then "" else "HH:mm"

    $(":input.date").datetimepicker('destroy').datetimepicker(dateTimeOpts)

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

  $(document).ajaxSuccess (e) ->
    $(AutoSet.selector).each ->
      AutoSet.trigger_all($(this))

  dialogOpts = {
    autoOpen: false
    resizable: false
    draggable: false
    modal: true
    width: 802
    height: 700
    dialogClass: 'no-close'
    beforeClose: ->
      $("body").css({ overflow: 'inherit' })
  }

  $("body").on "click", "div.ui-widget-overlay:visible", ->
      $(".ui-dialog.no-close:visible").find(".ui-dialog-content").dialog("close")

  # Modal overlay links
  $("a[rel='#overlay']").click (e) ->
    e.preventDefault()
    dialog = $('#overlay').dialog(dialogOpts).dialog('option', 'title', 'Loading...').dialog 'open'
    dialog.parent().css('z-index', '9999')
    $("body").css({ overflow: 'hidden' })
    dialog.load("#{@href} #page>.wrapper", ->
      dialog.dialog('option', 'title', dialog.find('h1').text())
      dialog.find('h1').remove()
      dialog.on "click", ".cancel a, .close", (e) ->
        e.preventDefault()
        dialog.dialog('close')
      return
    ) unless dialog.find('#page').length
    return

  $(".dialog-content").dialog(dialogOpts).on "click", ".cancel a, .close", (e) ->
    e.preventDefault()
    $(".dialog-content").dialog('close')

  $('a.open-dialog').click ->
    $(".dialog-content").dialog( "open" )

  $("#overlay form[data-remote]")
    .ajaxSuccess (e, data, status, xhr) ->
      $(this).parents(".inner:first").html(data)
    .ajaxError (e, xhr, status, error) ->
      $(this).parents(".inner:first").html(xhr.responseText)

  # Tools menu
  tools = $(".tools")
  tools.on "click", ->
    $(this).toggleClass("reveal")
  tools.on "touchend", ->
    $(this).addClass("reveal")
  tools.on "mouseleave", ->
    $(this).removeClass("reveal")

  $("div.group-selector").on "click", (e) ->
    $(this).toggleClass "open closed"

  # Autosize text areas, but only with the right CSS class
  $("textarea.autosize").autosize();
