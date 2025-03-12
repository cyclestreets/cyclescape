import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    $(this.element).on('cocoon:after-insert', this.checkToHideOrShowAddLink.bind(this))
    $(this.element).on('cocoon:after-remove', this.checkToHideOrShowAddLink.bind(this))

    this.checkToHideOrShowAddLink()
  }

  disconnect () {
    $(this.element).off('cocoon:after-insert', this.checkToHideOrShowAddLink.bind(this))
    $(this.element).off('cocoon:after-remove', this.checkToHideOrShowAddLink.bind(this))
  }

  checkToHideOrShowAddLink () {
    const nestedFields = this.element.querySelectorAll('.nested-fields')

    if (nestedFields.length <= 2) {
      this.element.querySelectorAll('.remove_fields').forEach((link) => (link.hidden = true))
    } else {
      this.element.querySelectorAll('.remove_fields').forEach((link) => (link.hidden = false))
    }

    if (nestedFields.length >= 4) {
      this.element.querySelector('.add_fields').hidden = true
    } else {
      this.element.querySelector('.add_fields').hidden = false
    }
  }
}
