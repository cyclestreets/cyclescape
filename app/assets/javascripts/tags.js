$(document).ready(function () {
  var setupTags = function () {
    $('div.tag-form').hide()
    $('div.tag-form li.cancel a').click(function () {
      $('div.tags').show()
      $('div.tag-form').hide()
    })

    $("a[rel='edit-tags']").click(function () {
      $('div.tags').hide()
      $('div.tag-form').show()
    })

    $('form.edit-tags').on('ajax:success', function (event) {
      const data = event.detail[0]
      $('div.tags-panel').replaceWith(data.tagspanel)
      setupTags()
    })

    $('form.edit-tags>fieldset.inputs input,[id$="tags_string"]').tagsInput({
      width: 'auto',
      autocomplete_url: '/tags/autocomplete_tag_name',
      removeWithBackspace: false
    })

    $('input,[id$="string_tag"]').focusout(function () {
      if ($(this).val() !== '') { $(this).trigger({type: 'keypress', which: 44, keyCode: 44}) }
      // add a comma (i.e. finish the tag) if the tag input is not empty. comma keyCode is 44
    })
  }
  setupTags()
})
