import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['shade', 'hamburger', 'groupPopover', 'sidebarNav']

  connect () {
    this.nav = $(this.sidebarNavTarget)
    this.shade = $(this.shadeTarget)
    this.hamburgerTarget.addEventListener('click', () => this.openNav())

    // Enable normal "click" close
    $('body').on('click', (event) => {
      if (event.target.tagName !== 'LI') {
        if (this.nav.hasClass('open')) {
          this.closeNav()
        }
      }
    })

    // Enable swipe-to-close
    this.nav.on('swipeleft', () => {
      if (this.nav.hasClass('open')) {
        this.closeNav()
      }
    })

    // Listen for escape key to close menu
    $(document).on('keydown', (event) => {
      if (event.key === 'Escape') {
        if (this.nav.hasClass('open')) {
          this.closeNav()
        }
      }
    })
  }

  openNav () {
    // Add shades
    this.shade.removeClass('white').fadeIn('fast')
    console.log('SidebarNavController openNav')

    // Slide the nav out from the left
    this.nav.show('slide', { direction: 'left' }, 300, () => {
      this.nav.addClass('open')
    })
  }

  closeNav () {
    try {
      const popover = bootstrap.Popover.getOrCreateInstance(this.groupPopoverTarget) // Returns a Bootstrap popover instance
      popover.hide()
    } catch (e) {
      // No popover found
    }
    // Close menu
    this.shade.fadeOut()
    this.nav.removeClass('open')
    this.nav.hide('slide', { direction: 'left' }, 300)
  }
}
