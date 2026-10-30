import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    const spinner = $(".autocomplete-spinner")

    $(".index input#groups").autocomplete({
      appendTo: ".group-search",
      source: function(request, response) {
        spinner.show();
        $.getJSON("/groups/autocomplete", { term: request.term }, function(data) {
          response(data);
        }).always(function() {
          spinner.hide();
        });
      },
      minLength: 2,
      select: function(event, ui) {
        window.location.href = ui.item.url;
      }
    });
  }
}
