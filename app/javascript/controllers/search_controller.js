import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['box', 'icon', 'input']

  // Clicking the search icon expands the box, clicking anywhere but the input closes it
  click (event) {
    if (event.target === this.inputTarget) return

    if (this.expanded) {
      this.close()
    } else if (this.boxTarget.contains(event.target)) {
      this.open()
    }
  }

  open () {
    this.boxTarget.classList.add('expanded')
    this.iconTarget.classList.replace('fa-search', 'fa-times-circle')
    this.inputTarget.focus()
  }

  close () {
    if (!this.expanded) return

    this.boxTarget.classList.remove('expanded')
    this.iconTarget.classList.replace('fa-times-circle', 'fa-search')
  }

  get expanded () {
    return this.boxTarget.classList.contains('expanded')
  }
}
