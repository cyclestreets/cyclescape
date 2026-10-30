import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['shade', 'groupPopover', 'sidebarNav']

  connect () {
    this.nav = $(this.sidebarNavTarget)
    this.shade = $(this.shadeTarget)

    // Swipe-to-close (jquery-touch-events only triggers jQuery events)
    this.nav.on('swipeleft', () => this.closeNav())
  }

  disconnect () {
    this.nav.off('swipeleft')
  }

  openNav () {
    // Add shades
    this.shade.removeClass('white').fadeIn('fast')

    // Slide the nav out from the left
    this.nav.show('slide', { direction: 'left' }, 300, () => {
      this.nav.addClass('open')
    })
  }

  // Clicking anywhere except a menu item closes the menu
  closeOnClick (event) {
    if (event.target.tagName !== 'LI') this.closeNav()
  }

  closeNav () {
    if (!this.nav.hasClass('open')) return

    if (this.hasGroupPopoverTarget) {
      bootstrap.Popover.getInstance(this.groupPopoverTarget)?.hide()
    }
    // Close menu
    this.shade.fadeOut()
    this.nav.removeClass('open')
    this.nav.hide('slide', { direction: 'left' }, 300)
  }
}
