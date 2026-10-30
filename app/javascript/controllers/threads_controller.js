import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['option', 'selection', 'label']

  connect () {
    this.currentView = this.selectedOption?.value
    this.updatePillPosition()
    this.setSegmentedControlIcons()
    window.addEventListener('resize', this.resizeHandler)
    this.restoreSavedView()
  }

  disconnect () {
    window.removeEventListener('resize', this.resizeHandler)
  }

  resizeHandler = () => {
    this.updatePillPosition()
    this.setSegmentedControlIcons()
  }

  updatePillPosition () {
    this.optionTargets.forEach((input, index) => {
      if (input.checked) {
        this.selectionTarget.style.transform = `translateX(${input.offsetWidth * index}px)`
      }
    })
  }

  setSegmentedControlIcons () {
    const showText = window.innerWidth > 1200
    this.labelTargets.forEach(span => {
      if (showText) {
        span.textContent = ' ' + span.dataset.text
      }
    })
  }

  // An explicit ?view= in the URL wins over the view saved in the cookie
  restoreSavedView () {
    if (new URL(window.location.href).searchParams.has('view')) return

    const option = this.optionTargets.find(input => input.value === Cookies.get(this.cookieName))
    if (option) {
      option.checked = true
      this.showView(option.value)
    }
  }

  navigate () {
    this.showView(this.selectedOption.value)
    Cookies.set(this.cookieName, this.currentView, { expires: 7 })
  }

  showView (view) {
    this.updatePillPosition()
    if (view === this.currentView) return

    this.currentView = view
    const url = new URL(window.location.href)
    url.searchParams.set('view', view)
    url.searchParams.delete('page')
    Turbo.visit(url, { frame: 'threads_frame' })
  }

  get selectedOption () {
    return this.optionTargets.find(input => input.checked)
  }

  get cookieName () {
    return `cyclescape-${document.body.className}`
  }
}
