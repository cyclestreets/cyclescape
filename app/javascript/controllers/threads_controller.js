import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['option', 'selection', 'label']

  connect () {
    this.updatePillPosition()
    this.setSegmentedControlIcons()
    window.addEventListener('resize', this.resizeHandler)
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

  navigate () {
    this.updatePillPosition()
    this.element.requestSubmit()
  }
}
