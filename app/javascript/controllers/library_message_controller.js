import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    this.scroller = $('.scrollable')
    this.scroller.slick({
      dots: false,
      arrows: false,
      adaptiveHeight: true,
      draggable: false,
    })

    this.panel = $('#from-library')
    this.form = this.panel.find('form.library-search')
    this.initial_items = ko.observableArray()
    this.results = ko.observableArray()
    this.selected_item = ko.observableArray()
    ko.applyBindings(this)

    this.form.on('ajax:success', this.show_results.bind(this))
    this.form.on('ajax:error', this.show_error)
    const that = this
    this.panel.on('click', 'a.select', function () { that.select(ko.dataFor(this)) } )
    this.fetch_initial_items()

    $('#from-library').on('click', 'a.select', (e) => {
      this.scroller.slick('slickNext')
      e.preventDefault()
    })

    $('#add-library-item > a.prev').click(() => this.scroller.slick('slickPrev'))

    $('a[href="#from-library"]').click(() => this.scroller.slick('setPosition'))
  }

  show_results (event) {
    this.results(event.detail[0])
    $('#library-relevant').hide()
    $('#library-results').show()
    this.scroller.slick('setPosition')
  }

  show_error (event) {
    console.log(event.detail)
  }

  select (item) {
    this.selected_item([item])
  }

  fetch_initial_items () {
    const url = this.panel.find('#library-relevant').data('src')
    $.ajax({
      url,
      success: data => {
        this.initial_items(data)
      }
    })
  }
}
