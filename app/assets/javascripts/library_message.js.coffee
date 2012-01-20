class LibrarySearchView
  constructor: (@form, @panel) ->
    # Rails will do the AJAX
    @form.data "remote", true
    @form.on "ajax:success", this.show_results
    @form.on "ajax:error", this.show_error

    # Select button
    self = this
    @panel.on "click", "a.select", (e) ->
      self.select(ko.dataFor(this))

    # Current result set
    @results = ko.observableArray()
    # Currently selected result
    @selected = ko.observable()

  library_items: => @results
  selected: => @selected

  show_results: (event, data, status, xhr) =>
    @results(data)
    @form.trigger "update_height"

  show_error: (xhr, status, error) =>
    console.log xhr, status, error

  select: (item) =>
    @selected(item)

jQuery ->
  $("form.library-search")
    .each ->
      form = $(this)
      target = $(form.attr("target"))
      ko.applyBindings new LibrarySearchView(form, target), target.get(0)
    .on "submit", ->
      $("#library-recent").hide()
      $("#library-results").show()

class LibraryItemsView
  constructor: (@panel, @url) ->
    @items = ko.observableArray()
    this.fetch_items()

  library_items: => @items

  fetch_items: ->
    $.ajax
      url: @panel.data("src")
      success: (data) =>
        @items(data)

jQuery ->
  $(".library-items").each ->
    ko.applyBindings new LibraryItemsView($(this)), this

  $("#from-library").on "click", "a.select", (e) ->
    scroller = $(this).parents(".scrollable:first").data("scrollable")
    scroller.next()
