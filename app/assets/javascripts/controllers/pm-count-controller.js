import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['count']

  connect () {
    if (this.hasCountTarget) {
      setTimeout(this.getPmCount.bind(this), 5000)
      setTimeout(this.getPmCount.bind(this), 20000)
    }
  }

  updatePmCount (count) {
    if (count > 0) {
      this.countTarget.textContent = count
      this.countTarget.hidden = false
    } else {
      this.countTarget.hidden = true
    }
  }

  getPmCount () {
    $.ajax({
      type: 'GET',
      url: '/private_messages',
      dataType: 'json',
      success: (data) => {
        Cookies.set('unviewed_private_count', data.count)
        this.updatePmCount(data.count)
      }
    })
  }
}
