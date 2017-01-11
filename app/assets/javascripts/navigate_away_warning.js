$(window).ready(function(){
  formEl = $('form.navigate-away-warning');

  if(formEl[0]){
    var confirmOnPageExit = function (e) {
      // If we haven't been passed the event get the window.event
      e = e || window.event;

      var message = CONSTANTS.i18n.navigateAwayWarning;

      // For IE6-8 and Firefox prior to version 4
      if (e) {
        e.returnValue = message;
      }

      // For Chrome, Safari, IE8+ and Opera 12+
      return message;
    };

    window.onbeforeunload = confirmOnPageExit;

    formEl.submit(function(){
      window.onbeforeunload = null;
    });
  }
});
