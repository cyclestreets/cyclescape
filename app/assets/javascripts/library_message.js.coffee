ko = require('knockout')
slick = require('slick-carousel-browserify')

class LibraryMessageView
  constructor: (@panel) ->
    # Items loaded at the start
    @initial_items = ko.observableArray()
    # Current result set
    @results = ko.observableArray()
    # Currently selected result
    @selected_item = ko.observableArray()

    ko.applyBindings(this)

    @form = @panel.find("form.library-search")
    # Rails will do the AJAX
    @form.data "remote", true
    @form.on "ajax:success", this.show_results
    @form.on "ajax:error", this.show_error

    # Select button
    self = this
    @panel.on "click", "a.select", (e) ->
      self.select(ko.dataFor(this))

    this.fetch_initial_items()

  initial_items: => @initial_items
  search_results: => @results
  selected: => @selected_item

  show_results: (event, data, status, xhr) =>
    @results(data)
    $("#library-recent").hide()
    $("#library-results").show()
    slick($('.scrollable'), 'setPosition')

  show_error: (xhr, status, error) ->
    console.log xhr, status, error

  select: (item) =>
    @selected_item([item])

  fetch_initial_items: =>
    url = @panel.find("#library-recent").data("src")
    $.ajax
      url: url
      success: (data) =>
        @initial_items(data)

jQuery ->
  scroller = $('.scrollable')
  slick(scroller, {
    dots: false
    arrows: false
    adaptiveHeight: true
    draggable: false
  })

  if $("#from-library").length > 0
    library_message_view = new LibraryMessageView($("#from-library"))

    # Select button
    $("#from-library").on "click", "a.select", (e) ->
      slick(scroller, 'slickNext')
      false

    $("#add-library-item > a.prev").click ->
      slick(scroller, 'slickPrev')

    $('a[href="#from-library"]').click ->
      slick(scroller, 'setPosition')
