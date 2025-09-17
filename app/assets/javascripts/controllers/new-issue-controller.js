import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['form', 'submit']

  toggle (event) {
    const checked = event.target.checked

    if (checked) {
      this.formTarget.style.display = 'block'
      this.submitTarget.value = this.submitTarget.dataset.startDiscussion
    } else {
      this.formTarget.style.display = 'none'
      this.submitTarget.value = this.submitTarget.dataset.noDiscussion
    }
  }
}
