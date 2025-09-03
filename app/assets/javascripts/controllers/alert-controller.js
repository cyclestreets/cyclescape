import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['close']

  connect () {
    this.closeTarget.addEventListener('click', () => $(this.element).alert('close'))
  }
}
