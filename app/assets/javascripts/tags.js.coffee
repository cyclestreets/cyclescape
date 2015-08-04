$ ->
  $("div.tag-form li.cancel a").click ->
    $("div.tags").show()
    $("div.tag-form").hide()
    return

  $("a[rel='edit-tags']").click ->
    $("div.tags").hide()
    $("div.tag-form").show()
    return

  $("form.edit-tags").live "ajax:success", (e, data, status, xhr) ->
    $("div.tags-panel").replaceWith(data.tagspanel)
    $("div.tags").show()
    $("div.tag-form").hide()
    $("section.library.box").replaceWith(data.librarypanel) if data.librarypanel
    return

  $("div.tag-form").hide()
  return
