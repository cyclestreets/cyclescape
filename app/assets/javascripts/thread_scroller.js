$(document).ready(function() {
  if(!window.location.hash) {
    $('html, body').animate({
        scrollTop: $(".thread-view-from-here").offset().top
    }, 2000);
  }
});
