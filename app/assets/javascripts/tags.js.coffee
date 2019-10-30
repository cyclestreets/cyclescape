$ ->
  setupTags = ->
    $("div.tag-form").hide()
    $("div.tag-form li.cancel a").click ->
      $("div.tags").show()
      $("div.tag-form").hide()
      return

    $("a[rel='edit-tags']").click ->
      $("div.tags").hide()
      $("div.tag-form").show()
      return

    $("form.edit-tags").on "ajax:success", (event) ->
      data = event.detail[0]
      $("div.tags-panel").replaceWith(data.tagspanel)
      setupTags()
      return

    $('form.edit-tags>fieldset.inputs input,[id$="tags_string"]').tagsInput({
      width: 'auto',
      autocomplete_url: '/tags/autocomplete_tag_name',
      removeWithBackspace: false,
    })

    $('input,[id$="string_tag"]').focusout( ->
      $(@).trigger(type: 'keypress', which: 44, keyCode: 44) if ($(@).val() != '')
      # add a comma (i.e. finish the tag) if the tag input is not empty. comma keyCode is 44
    )
  setupTags()
