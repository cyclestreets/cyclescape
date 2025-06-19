import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['option', 'selection', 'label']

  connect () {
    this.updatePillPosition()
    this.setSegmentedControlIcons()

    this.optionTargets.forEach((option) => {
      option.addEventListener('change', this.navigate)
    })

    window.addEventListener('resize', this.resizeHandler)

    this.restoreSegmentedControlState()
  }

  disconnect () {
    window.removeEventListener('resize', this.resizeHandler)
    this.optionTargets.forEach((option) => {
      option.removeEventListener('change', this.navigate)
    })
  }

  resizeHandler = () => {
    this.updatePillPosition()
    this.setSegmentedControlIcons()
  }

  updatePillPosition = () => {
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

  restoreSegmentedControlState () {
    const pageId = 'cyclescape-' + document.body.className
    const savedCookie = Cookies.get(pageId)

    if (savedCookie) {
      this.optionTargets.forEach((input, index) => {
        if (input.value === savedCookie) {
          input.checked = true
          input.dispatchEvent(new Event('change'))
        }
      })
    }
  }

  navigate = (event) => {
    const url = new URL(window.location.href)
    url.searchParams.set('view', event.target.value)

    Turbo.visit(url.toString(), { frame: 'threads_frame' })
    this.updatePillPosition()
  }

  saveState () {
    const selected = this.optionTargets.find(input => input.checked)
    if (!selected) return

    const pageId = `cyclescape-${document.body.className}`
    Cookies.set(pageId, selected.value, { expires: 7 })
  }
}
