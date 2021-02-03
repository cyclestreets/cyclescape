require('autosize/build/jquery.autosize.js')

window.jsonpTransportRequired = ->
  navigator.appVersion.indexOf('MSIE') != -1 &&
    parseFloat(navigator.appVersion.split('MSIE')[1]) <= 9

jQuery ->
  $("#issue_start_discussion").change((evt)->
    form = $("[data='start-discussion-form']")
    btn = $(form).parent().find("input[type=submit]")
    if (evt.target.checked)
      form.show()
      btn.prop('value', btn.data("startDiscussion"))
    else
      form.hide()
      btn.prop('value', btn.data("noDiscussion"))
  )

  # Tabs
  $(".tabs").parent().tabs()

  unviewed_private_count = $("#unviewed-pm-count")

  updatePmCount = (count)->
    if count > 0
      unviewed_private_count.text(count).addClass("text-image-overlay")
    else
      unviewed_private_count.removeClass("text-image-overlay")


  if unviewed_private_count[0]
    updatePmCount($.cookie('unviewed_private_count'))
    getPmCount = ()->
      $.ajax
        type: "GET"
        url: "/private_messages"
        dataType: "json"
        success: (data) ->
          $.cookie('unviewed_private_count', data.count)
          updatePmCount(data.count)

    setTimeout(getPmCount, 5000)
    setTimeout(getPmCount, 20000)

  $(document).on("keypress", "input.search-input", (event) ->
    # do not submit from when searching
    event.preventDefault() if (event.keyCode == 13)
  )

  if history.pushState
    $(".tabs").parent().on "tabsactivate", (event, ui) ->
      history.pushState(null, null, "##{ui.newPanel.attr('id')}")

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

  window.dateTimeInit = ->
    dateTimeOpts = {
      dateFormat: "dd-mm-yy"
      stepMinute: 15
      firstDay: 1
      showButtonPanel: false
      minDateTime: new Date((new(Date)).setMinutes(0))
    }

    # Apply date selector to all date inputs
    $(":input.date").datetimepicker( dateTimeOpts )

    $(".all-day:input").change ->

      dateTimeOpts.showTimepicker =  !$(@).is(':checked')
      dateTimeOpts.timeFormat = if($(@).is(':checked')) then "" else "HH:mm"

      $(":input.date").datetimepicker('destroy').datetimepicker(dateTimeOpts)
  window.dateTimeInit()
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
        target_select.empty().addOption(new_options)

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
  $(AutoSet.selector).each ->
    AutoSet.trigger_all($(this))

  $(document).on "change", AutoSet.selector, ->
    AutoSet.trigger_all($(this))

  $(document).on "ajax:success", ->
    $(AutoSet.selector).each ->
      AutoSet.trigger_all($(this))

  # Tools menu
  tools = $(".tools")
  tools.on "click", ->
    $(this).toggleClass("reveal")
  tools.on "touchend", ->
    $(this).addClass("reveal")
  tools.on "mouseleave", ->
    $(this).removeClass("reveal")

  groupSelector = $("div.group-selector")
  groupSelector.on "click", (e) ->
    groupSelector.toggleClass "open"
  groupSelector.on "mouseleave", ->
    setTimeout(->
      groupSelector.removeClass "open"
    , 500)

  # Autosize text areas, but only with the right CSS class
  $("textarea.autosize").autosize()

  $(document).scroll ()->
    pixelsScrolled = $(@).scrollTop()
    if (pixelsScrolled > 75)
      $('#main-nav, #crumb-search').addClass("top-fix")
      $('#site-header').addClass('top-nudge')
    else
      $('#main-nav, #crumb-search').removeClass("top-fix")
      $('#site-header').removeClass('top-nudge')

  copyFrom = (copyToEl)->
    ->
      return if copyToEl.data("touched")
      copyToEl.val(this.value)

  $("[data-copyfromid]").each( ->
    copyToEl = $(this)
    copyToEl.data("touched", true) if !!copyToEl.val()
    copyToEl.on("propertychange change keyup input paste", ->
      copyToEl.data("touched", true)
    )
    $(copyToEl.data("copyfromid")).on("propertychange change click keyup input paste", copyFrom(copyToEl))
  )
