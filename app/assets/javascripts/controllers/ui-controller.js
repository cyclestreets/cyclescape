import { Controller } from '@hotwired/stimulus'

require('autosize/build/jquery.autosize.js')
require('jquery-ui/tabs')

export default class extends Controller {
  connect () {
    this.initialize()
    this.navigateAwayWarning()
    this.toolMenu()
    window.leafletMapInit()
    window.streetViewInit()
    window.initImageEdit()
    $('time.timeago').timeago()
    $('textarea.tinymce').closest('form').find('input:submit').prop('disabled', true)
    tinyMCE.init(window.tinymceOpts)
  }

  initialize () {
    // Tabs
    $('.tabs').parent().tabs()

    $(document).on('keypress', 'input.search-input', function (event) {
      // do not submit from when searching
      if (event.keyCode === 13) { event.preventDefault() }
    })

    if (history.pushState) {
      $('.tabs').parent().on('tabsactivate', (event, ui) => history.pushState(null, null, `#${ui.newPanel.attr('id')}`))
    }

    // Crude way to make large blocks .clickable by definiting a.primary-link in them
    $('.clickable').click(function () {
      window.location.href = $(this).find('a.primary-link').attr('href')
    })

    // When .collapsible item is hovered in/out the .collapse elements inside
    // expand and collapse
    $('.collapsible').hover(
      $(this).find('.collapse').slideDown,
      $(this).find('.collapse').slideUp
    ).find('.collapse').hide()

    // Automatic setting of values and visibility from select drop-downs
    const AutoSet = {
      selector: 'select',

      triggerAll (sourceSelect) {
        this.updateOptions(sourceSelect)
        this.updateValue(sourceSelect)
        this.updateVisibility(sourceSelect)
      },

      // When a select box is changed search for other selects that
      // are linked via the auto-options and auto-options-param data
      // attributes and update the target select box with the new options.
      updateOptions (sourceSelect) {
        $(`select[data-auto-options='#${sourceSelect.attr('id')}']`).each(function () {
          const targetSelect = $(this)
          const param = targetSelect.data('auto-options-param')
          const newOptions = sourceSelect.find('option:selected').data(param)
          targetSelect.empty().addOption(newOptions)
        })
      },

      // When a select box is changed search for other selects that
      // are linked via the autoset and autoset-param data attributes
      // and update them with the new value.
      updateValue (sourceSelect) {
        $(`select[data-autoset='#${sourceSelect.attr('id')}']`).each(function () {
          const targetSelect = $(this)
          const param = targetSelect.data('autoset-param')
          const newValue = sourceSelect.find('option:selected').data(param)
          targetSelect.val(newValue)
        })
      },

      // When a select box is changed find any dependent elements and
      // hide or show based on whether the new value is blank or not.
      updateVisibility (sourceSelect) {
        $(`*[data-dependent='#${sourceSelect.attr('id')}']`).each(function () {
          const target = $(this)
          if (sourceSelect.val() !== '') {
            target.show()
          } else {
            target.hide()
          }
        })
      }
    }
    $(AutoSet.selector).each(function () {
      AutoSet.triggerAll($(this))
    })

    $(document).on('change', AutoSet.selector, function () {
      AutoSet.triggerAll($(this))
    })

    $(document).on('ajax:success', () => $(AutoSet.selector).each(function () {
      AutoSet.triggerAll($(this))
    }))

    const groupSelector = $('div.group-selector')
    groupSelector.on('click', e => groupSelector.toggleClass('open'))
    groupSelector.on('mouseleave', () => setTimeout(() => groupSelector.removeClass('open'), 500))

    // Autosize text areas, but only with the right CSS class
    $('textarea.autosize').autosize()

    const copyFrom = function (toEl) {
      return function () {
        if (toEl.data('touched')) { return }
        toEl.val(this.value)
      }
    }

    $('[data-copyfromid]').each(function () {
      const toEl = $(this)
      const fromEl = $(toEl.data('copyfromid'))
      if (toEl.val()) { toEl.data('touched', true) }
      toEl.on('propertychange change keyup input paste', () => toEl.data('touched', true))
      fromEl.on('propertychange change click keyup input paste', copyFrom(toEl))
    })
  }

  navigateAwayWarning () {
    const formEl = $('form.navigate-away-warning')

    formEl.find(':input').each(function () {
      $(this).data('initialValue', $(this).val())
    })

    if (formEl[0]) {
      const confirmOnPageExit = function (e) {
        let isClean = true

        formEl.find(':input').each(function () {
          const initialValue = $(this).data('initialValue')
          if (initialValue && initialValue !== $(this).val()) {
            isClean = false
          }
        })
        if (isClean) {
          return
        }

        // If we haven't been passed the event get the window.event
        e = e || window.event

        const message = CONSTANTS.i18n.navigateAwayWarning

        // For IE6-8 and Firefox prior to version 4
        if (e) {
          e.returnValue = message
        }

        // For Chrome, Safari, IE8+ and Opera 12+
        return message
      }

      window.onbeforeunload = confirmOnPageExit

      formEl.submit(function () {
        window.onbeforeunload = null
      })
    }
  }

  toolMenu () {
    const tools = document.querySelectorAll('.tools')
    tools.forEach(tool => {
      let leaveTimeout

      tool.addEventListener('click', function () {
        this.classList.toggle('reveal')
      })

      tool.addEventListener('touchend', function () {
        this.classList.add('reveal')
      })

      tool.addEventListener('mouseleave', function () {
        if (!leaveTimeout) {
          leaveTimeout = setTimeout(() => {
            this.classList.remove('reveal')
          }, 1000)
        }
      })

      tool.addEventListener('mouseenter', function () {
        if (leaveTimeout) {
          clearTimeout(leaveTimeout)
        }
      })
    })
  }
}
