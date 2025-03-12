class LibraryMessageView {
  constructor (panel) {
    // Items loaded at the start
    this.initial_items = this.initial_items.bind(this)
    this.search_results = this.search_results.bind(this)
    this.selected = this.selected.bind(this)
    this.showResults = this.showResults.bind(this)
    this.select = this.select.bind(this)
    this.fetchInitialItems = this.fetchInitialItems.bind(this)
    this.panel = panel
    this.initial_items = ko.observableArray()
    // Current result set
    this.results = ko.observableArray()
    // Currently selected result
    this.selected_item = ko.observableArray()

    ko.applyBindings(this)

    this.form = this.panel.find('form.library-search')
    this.form.on('ajax:success', this.showResults)
    this.form.on('ajax:error', this.showError)

    // Select button
    const self = this
    this.panel.on('click', 'a.select', function (e) {
      return self.select(ko.dataFor(this))
    })

    this.fetchInitialItems()
  }

  initial_items () { return this.initial_items }
  search_results () { return this.results }
  selected () { return this.selected_item }

  showResults (event, data, status, xhr) {
    this.results(event.detail[0])
    $('#library-relevant').hide()
    $('#library-results').show()
    return $('.scrollable').slick('setPosition')
  }

  showError (event) {
    return console.log(event.detail)
  }

  select (item) {
    return this.selected_item([item])
  }

  fetchInitialItems () {
    const url = this.panel.find('#library-relevant').data('src')
    return $.ajax({
      url,
      success: data => {
        return this.initial_items(data)
      }
    })
  }
}

jQuery(function () {
  const scroller = $('.scrollable')
  scroller.slick({
    dots: false,
    arrows: false,
    adaptiveHeight: true,
    draggable: false
  })

  if ($('#from-library').length > 0) {
    new LibraryMessageView($('#from-library'))

    // Select button
    $('#from-library').on('click', 'a.select', function (e) {
      scroller.slick('slickNext')
      return false
    })

    $('#add-library-item > a.prev').click(() => scroller.slick('slickPrev'))

    return $('a[href="#from-library"]').click(() => scroller.slick('setPosition'))
  }
})
