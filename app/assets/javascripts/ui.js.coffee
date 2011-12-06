jQuery ->
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

  # When a select box is changed search for other selects that
  # are linked via the autoset and autoset-param data attributes
  # and update them with the new value.
  $(document).on "change", "select", ->
    source_select = $ this
    $("select[data-autoset='##{this.id}']").each ->
      target_select = $ this
      param = target_select.data("autoset-param")
      new_value = source_select.find("option:selected").data(param)
      console.info source_select, target_select, param, new_value
      target_select.val(new_value)

  # When a select box is changed find any dependent elements and
  # hide or show based on whether the new value is blank or not.
  $(document).on "change", "select", ->
    source_select = $ this
    $("*[data-dependent='##{this.id}']").each ->
      target = $ this
      if source_select.val() != ""
        target.show()
      else
        target.hide()
