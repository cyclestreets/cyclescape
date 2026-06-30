import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    const that = this
    const _settings = { disactivateCloseSearch: false }

    $('#search').on('click', function () {
      if (!$('#search').hasClass('expanded')) {
        $('#search i').toggleClass('fa-search').toggleClass('fa-times-circle')
        $('#search').addClass('expanded')

        $('#search input').focus()
        _settings.disactivateCloseSearch = true
        setTimeout(function () {
          _settings.disactivateCloseSearch = false
        }, 100)
      }
    })

    // Close search box on escape key
    document.onkeydown = function (evt) {
      evt = evt || window.event
      let isEscape = false
      if ('key' in evt) {
        isEscape = (evt.key === 'Escape' || evt.key === 'Esc')
      } else {
        isEscape = (evt.keyCode === 27)
      }
      if (isEscape) {
        that.closeSearchBar(_settings)
      }
    }

    // Close the search bar if clicking on the x
    $('#search fa-times-circle').on('click', function () {
      that.closeSearchBar(_settings)
    })

    // Close the search bar if clicking outside it
    $('body').on('click', function (event) {
      if (event.target.localName !== 'input') {
        that.closeSearchBar(_settings)
      }
    })
  }

  // Close search bar
  closeSearchBar (_settings) {
    if ($('#search').hasClass('expanded') && _settings.disactivateCloseSearch === false) {
      $('#search').removeClass('expanded')
      $('#search i').toggleClass('fa-search').toggleClass('fa-times-circle')
    }
  }
}
