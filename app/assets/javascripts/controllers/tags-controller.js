import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    const el = $(this.element)
    $(el).tagsInput({
      width: 'auto',
      autocomplete_url: '/tags/autocomplete_tag_name',
      removeWithBackspace: false
    })

    $(el).focusout(function () {
      if ($(el).val() !== '') { $(el).trigger({ type: 'keypress', which: 44, keyCode: 44 }) }
      // add a comma (i.e. finish the tag) if the tag input is not empty. comma keyCode is 44
    })
  }
}
