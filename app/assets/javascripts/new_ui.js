/* global $, window */

var cyclescapeui = (function ($) {
  'use strict'

  var _pageScroll = 0 // Save page scroll when opening an overlay on mobile
  const isIOSSafari = !!window.navigator.userAgent.match(/Version\/[\d\.]+.*Safari/)

  return {

    // Main function
    initialise: function () {
      cyclescapeui.sideContent();
    },

    // Set up mobile side-content view
    sideContent: function () {
      // Handle filter button
      $('.show-side-content').on('click', function () {
        if ($('.side-content').hasClass('visible')) {
          cyclescapeui.closeSideContent();
        } else {
          _pageScroll = cyclescapeui.getPageScroll();
          window.scrollTo(0, 0);
          $('.show-side-content').html('Done <i class="fas fa-fw fa-check"></i>');
          $('#shade').addClass('white').fadeIn('fast');
          $('.side-content').addClass('visible').show()
        }
      });

      // Close button
      $('#shade>i.close').on('click', function () {
        cyclescapeui.closeSideContent();
      });

      // If we have hidden the side content and window resizes, CSS doesn't kick it - override
      $(window).on('resize', function () {
        if (isIOSSafari) { return; }
        if ($(window).width() > 768) {
          $('.side-content').show();
        } else {
          $('.side-content').hide();
        }
      });
    },


    // Close side content
    closeSideContent: function () {
      $('.show-side-content').html('Filter <i class="fas fa-fw fa-filter"></i>');
      $('#shade').fadeOut('fast');
      $('.side-content').removeClass('visible').hide();
      window.scrollTo(0, _pageScroll);
    },


    // This function simply gets the window scroll position, works in all browsers.
    getPageScroll: function () {
      var yScroll;
      if (self.pageYOffset) {
        yScroll = self.pageYOffset;
      } else if (document.documentElement && document.documentElement.scrollTop) {
        yScroll = document.documentElement.scrollTop;
      } else if (document.body) {
        yScroll = document.body.scrollTop;
      }
      return yScroll;
    },
  };
}(jQuery))

$(function () {
  cyclescapeui.initialise()
})
