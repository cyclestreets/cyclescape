import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['collisions', 'photos']

  connect () {
    const layers = [
      {
        map: $("span:contains('Collisions')").prev(),
        checkbox: this.collisionsTarget
      },
      {
        map: $("span:contains('Photos')").prev(),
        checkbox: this.photosTarget
      }
    ]

    layers.forEach(({ map, checkbox }) => {
      if (map && checkbox) {
        this.setupMapCheckboxPair(map, checkbox)
      }
    })
  }

  setupMapCheckboxPair (map, checkbox) {
    map.change(function () {
      checkbox.checked = this.checked
    })

    checkbox.addEventListener('change', () => {
      map.click()
    })
  }
}
