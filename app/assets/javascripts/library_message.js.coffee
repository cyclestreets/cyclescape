class LibraryMessageView
  constructor: (@panel) ->
    # Items loaded at the start
    @initial_items = ko.observableArray()
    # Current result set
    @results = ko.observableArray()
    # Currently selected result
    @selected = ko.observable()

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
    @initial_items.subscribe (new_val) =>
      @panel.find(".scrollable").trigger("update_height")

  initial_items: => @initial_items
  search_results: => @results
  selected: => @selected

  show_results: (event, data, status, xhr) =>
    @results(data)
    $("#library-recent").hide()
    $("#library-results").show()
    @form.trigger "update_height"

  show_error: (xhr, status, error) =>
    console.log xhr, status, error

  select: (item) =>
    @selected(item)

  fetch_initial_items: =>
    url = @panel.find("#library-recent").data("src")
    $.ajax
      url: url
      success: (data) =>
        @initial_items(data)

jQuery ->
  library_message_view = new LibraryMessageView($("#from-library"))

  # Select button
  $("#from-library").on "click", "a.select", (e) ->
    scroller = $(this).parents(".scrollable:first").data("scrollable")
    scroller.next()
    false

  # Tab click event to update the height
  $("section.new-message > ul.tabs").on "onClick", ->
    scroller = $(this).parents("section:first").find(".scrollable")
    scroller.trigger "update_height"
