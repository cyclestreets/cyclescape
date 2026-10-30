import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    this.popover = bootstrap.Popover.getOrCreateInstance(this.element)
  }

  disconnect () {
    this.popover.dispose()
  }
}
