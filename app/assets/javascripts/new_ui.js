/* jslint browser: true, white: true, single: true, for: true, long: true */
/* global $, console, window, CONSTANTS */

var cyclescapeui = (function ($) {
  'use strict'

  // Default settings
  var _actions = [
    'index',
    'discussion',
    'newIdea',
    'profile',
    'newDiscussion'
  ]

  // Class properties
  var _currentWizardPage = 0 // Current page on progress div pages i.e. account creation
  var _pageScroll = 0 // Save page scroll when opening an overlay on mobile
  var _sideContentHtml = ''
  const isIOSSafari = !!window.navigator.userAgent.match(/Version\/[\d\.]+.*Safari/)

  var _map = null; // Leaflet map
  var _addIdeaMarker = null; // Save the Leaflet marker in newIdea
  var _selectedAttachment = null; // Selected attachment in Discussion view


  return {

    // Main function
    initialise: function (page = false) {
      // Initialise the UI
      cyclescapeui.filterable();
      cyclescapeui.uploadPreview();
      cyclescapeui.autofocus();
      cyclescapeui.geocoder();
      cyclescapeui.sideContent();
      cyclescapeui.mapControls();
      cyclescapeui.popovers();
      cyclescapeui.toasts();
      cyclescapeui.enableWizard();

      // Initialise each section
      if (_actions.includes(page)) {
        cyclescapeui[page]();
      };
    },

    // Autofocus inputs contained in Bootstrap modals
    autofocus: function () {
      $(document).on('shown.bs.modal', function () {
        $('input:visible:enabled:first', this).focus();
      });
    },

    // Enable preview of photos to be uploaded
    thumbWrapper: function (files, selector) {

      thumb(files);

      function thumb(files) {

        if (files == null || files == undefined) {
          $(selector).html('<p><em>Unable to show a thumbnail, as this web browser is too old to support this.</em></p>');
          return false;
        }

        for (var i = 0; i < files.length; i++) {
          var file = files[i];
          var imageType = /image.*/;

          if (!file.type.match(imageType)) {
            continue;
          }

          var reader = new FileReader();

          if (reader != null) {
            reader.onload = GetThumbnail;
            reader.readAsDataURL(file);
          }
        }
      }

      function GetThumbnail(e) {

        var thumbnailCanvas = document.createElement('canvas');
        var img = new Image();
        img.src = e.target.result;

        img.onload = function () {

          var originalImageWidth = img.width;
          var originalImageHeight = img.height;

          thumbnailCanvas.id = 'myTempCanvas';
          thumbnailCanvas.width = $(selector).width();
          thumbnailCanvas.height = $(selector).height();

          // Scale the thumbnail to fit the box
          if (originalImageWidth >= originalImageHeight) {
            var scaledWidth = Math.min(thumbnailCanvas.width, originalImageWidth);	// Ensure width is no greater than the available size
            var scaleFactor = (scaledWidth / originalImageWidth);
            var scaledHeight = Math.round(scaleFactor * originalImageHeight);	// Scale to same proportion, and round
          } else {
            var scaledHeight = Math.min(thumbnailCanvas.height, originalImageHeight);
            var scaleFactor = (scaledHeight / originalImageHeight);
            var scaledWidth = Math.round(scaleFactor * originalImageWidth);
          }

          if (thumbnailCanvas.getContext) {
            var canvasContext = thumbnailCanvas.getContext('2d');
            canvasContext.drawImage(img, 0, 0, scaledWidth, scaledHeight);
            var dataURL = thumbnailCanvas.toDataURL();

            if (dataURL != null && dataURL != undefined) {
              var nImg = document.createElement('img');
              nImg.src = dataURL;
              $(selector).html(nImg);
            } else {
              $(selector).html('<p><em>Unable to read the image.</em></p>');
            }
          }
        }
      }
    },


    uploadPreview: function () {
      $('#form_photograph').on('change', function () {
        cyclescapeui.thumbWrapper(this.files, '#form_thumbnailpreview');
      });
    },

    // Enable geocoder animations
    geocoder: function () {
      $('.geocoder i').on('click', function () {
        $('.geocoder').toggleClass('expanded');
        $('.geocoder i').toggleClass('fa-search').toggleClass('fa-times');
        $('.geocoder input').focus()
      });
    },

    // Enable Bootstrap popovers
    popovers: function () {
      var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
      var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl)
      });
    },


    // Enable Bootstrap toasts
    toasts: function () {
      var toastElList = [].slice.call(document.querySelectorAll('.toast'))
      var toastList = toastElList.map(function (toastEl) {
        return new bootstrap.Toast(toastEl, { animation: true, delay: 1500 })
      });
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


    // Enable type-to-filter (TTF) in library and other views
    filterable: function () {
      $('input.filter').on('keyup', function () {
        var value = $(this).val().toLowerCase();
        $('.filterable h2').filter(function () {
          $(this).closest('li').toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
      });
    },


    // Set up mobile side-content view
    mapControls: function () {
      // Close button
      $('#shade>i.close').on('click', function () {
        cyclescapeui.closeMapControls();
        cyclescapeui.closeSideContent();
      });


      // Handle clicking
      $('.map-buttons li').on('click', function () {
        $('.map-buttons li').removeClass('active');
        $(this).addClass('active');
      })

      // Handle filter button
      $('.show-map-controls').on('click', function () {
        if ($('.map-controls').hasClass('visible')) {
          var openText = $(this).data('open-text') + ' <i class="' + $(this).data('open-icon') + '"></i>'
          cyclescapeui.closeMapControls(openText);
        } else {
          _pageScroll = cyclescapeui.getPageScroll();
          window.scrollTo(0, 0);
          $('.show-map-controls').html($(this).data('close-text') + ' <i class="' + $(this).data('close-icon') + '"></i>');
          $('#shade').addClass('white').fadeIn('fast')
          $('.map-controls').css('z-index', '101').show().addClass('visible');
        }
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


    closeMapControls: function (buttonLabel = 'Filter <i class="fas fa-fw fa-filter"></i>') {
      $('.show-map-controls').html(buttonLabel);
      $('#shade').fadeOut('fast');
      $('.map-controls').removeClass('visible').hide();
      window.scrollTo(0, _pageScroll);
    },

    // Enable progress toggles between pages in a progress div
    // Ex. account creation wizard
    enableWizard: function () {
      // At page launch, hide all but default wizard div
      if ($('.wizard-content').length) {
        cyclescapeui.showWizardDiv(_currentWizardPage);
      }

      cyclescapeui.updateWizardBreadcrumbs();

      // Enable clicking between divs
      $('.wizard-content button.next').on('click', function () {
        // Advance to next div
        _currentWizardPage += 1;

        // Get all divs
        var divs = $('.wizard-content>div');

        // Hide all
        divs.hide();

        // Show the next one
        if (_currentWizardPage < divs.length) {
          $(divs[_currentWizardPage]).show();

          // If last div, confetti!
          if (_currentWizardPage == (divs.length - 1)) {
            const jsConfetti = new JSConfetti();
            jsConfetti.addConfetti();
          }
        }

        cyclescapeui.updateWizardBreadcrumbs();

        // Autofocus on the first field
        $('input').first().focus();
      });

      // Enable clicking on wizard breadcrumps
      $('.wizard li').on('click', function () {
        var clickedTabIndex = $('.wizard li').index(this);
        _currentWizardPage = clickedTabIndex;
        cyclescapeui.showWizardDiv(clickedTabIndex);
      });

      // Enable back arrow
      $('.wizard-back').on('click', function () {
        _currentWizardPage -= 1
        cyclescapeui.showWizardDiv(_currentWizardPage);
      });
    },


    // Takes a number and shows the corresponding div index
    showWizardDiv: function (divIndex) {
      // Get all divs
      var divs = $('.wizard-content>div');

      // Hide all
      divs.hide();

      // Show the next one
      if (divIndex < divs.length) {
        $(divs[divIndex]).show();
      }

      // Autofocus on the first field
      $('input').first().focus();

      cyclescapeui.updateWizardBreadcrumbs();
    },


    // Update wizard progress chip coloors
    updateWizardBreadcrumbs: function () {
      var wizardCrumbs = $('ul.wizard>li>h2')

      // Colour any complete crumbs
      for (var i = 0; i < _currentWizardPage; i++) {
        $(wizardCrumbs[i]).removeClass('active').addClass('complete');
      }

      // Colour the current crumb
      $(wizardCrumbs[_currentWizardPage]).addClass('active');
    },


    // Display a notification popup with a message
    displayNotification: function (notificationText, imageSrc, callback) {

      // Add this notification to the queue
      _notificationQueue.push({
        'notificationText': notificationText,
        'imageSrc': imageSrc,
        'callback': callback
      });

      // If the display daemon is already working through a queue, let it do its job
      if ($('.popup.system-notification').queue('fx').length) {
        return;
      }

      // Otherwise start to work through the notification queue
      cyclescapeui.notificationDaemon();
    },


    // Function to work through a queue of notifications. Will exit after the last notification is shown
    notificationDaemon: function () {
      // If there are items in the queue that haven't been displayed
      var notification = null;
      if (_notificationQueue.length) {

        // Pop the array
        notification = _notificationQueue.shift();

        // Set the image and text
        $('.popup.system-notification img').attr('src', notification.imageSrc);
        $('.popup.system-notification p.direction').text(notification.notificationText);

        // If we received a callback, change the click event to this
        if (notification.callback) {
          $('.notification').one('click', function () {
            notification.callback();
          });
        }

        // Slide down the notification, and hide it after a delay
        // Upon completetion, call this function again
        $('.popup.system-notification').slideDown('slow');
        $('.popup.system-notification').delay(2500).slideUp('slow', cyclescapeui.notificationDaemon);
      }
    },


    // Page-specific initialisation
    // Page-specific initialisation
    discussion: function () {
      var addContentModal = new bootstrap.Modal(document.getElementById('addContentModal'), {})

      cyclescapeui.initFavourites()

      // Clicking a like button likes the post
      $('.like').on('click', function () {
        $(this).toggleClass('liked');

        $(this).toggleClass('animate__heartBeat', $(this).hasClass('liked'));
      });

      // Clicking an added piece of rich-content prompts to delete it
      $('ul.attachments li.attachment').on('click', function () {
        _selectedAttachment = $(this);
        $('#deleteModal').modal('toggle')
      });

      // Handler for deleteModal delete button
      $('.remove-attachment').on('click', function () {
        $('#deleteModal').modal('toggle');
        _selectedAttachment.fadeOut();
      });

      // Enable rich-content-adding modal
      $('body').on('click', 'ul.add-content li', function () {
        addContentModal.toggle();
      });

      // Initialise tinymce
      tinymce.init({
        selector: 'textarea',
        plugins: 'autoresize',
        statusbar: false,
        menubar: false,
        skin: (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'oxide-dark' : 'oxide'),
        content_css: (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default')
      });

      // Clicking reply adds that text to the editor
      $('.post-actions .reply').on('click', function () {
        var quotedText = $(this).parent('.post-actions').siblings('.content').find('.post').first().text();
        tinymce.activeEditor.setContent(tinymce.activeEditor.getContent() + '<blockquote>' + quotedText + '</blockquote><br/> <br/>');

        // Animate scrolling to bottom
        $('html, body').animate({
          scrollTop: $('li.reply').offset().top
        }, 1000);

        // Set focus (to last line) in editor
        tinyMCE.activeEditor.selection.select(tinyMCE.activeEditor.getBody(), true);
        tinyMCE.activeEditor.selection.collapse(false);
        tinyMCE.activeEditor.focus();

      });
    },


    // Page-specific initialisation
    newIdea: function () {
      // Initialise map
      _map = L.map('map', {
        zoomControl: false,
        tap: false // c.f. https://stackoverflow.com/questions/65030691/click-event-fires-twice-for-item-inside-a-loop
      }).setView([51.505, -0.09], 13);

      // Add zoom control to bottom right
      L.control.zoom({
        position: 'bottomright'
      }).addTo(_map);

      // Load in a tile layer
      L.tileLayer(`https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=${CONSTANTS.mapboxglAccessToken}`, {
        attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
        maxZoom: 18,
        id: 'mapbox/streets-v11',
        tileSize: 512,
        zoomOffset: -1,
        accessToken: CONSTANTS.mapboxglAccessToken
      }).addTo(_map);

      // On click, add a marker
      _map.on('click', function (e) {
        console.log();
        // Set a quick marker first, which will be adjusted once the API call comes back
        if (_addIdeaMarker) {
          _addIdeaMarker.setLatLng(e.latlng).update();
        } else {
          _addIdeaMarker = L.marker(e.latlng).addTo(_map);
        }

        // Get CycleStreets nearest point to update marker and location name
        cyclescapeui.getNearestPoint(e.latlng.lng, e.latlng.lat, function (response) {
          cyclescapeui.setMarker([response.features[0].geometry.coordinates[1], response.features[0].geometry.coordinates[0]]);
          cyclescapeui.setName(response.features[0].properties.name);
        });
      });

      // Exceptionally, this page has a button to hide/show side-panel when in desktop view
      $('.show-side-panel').on('click', function () {
        $('.map-controls').slideToggle();
      });

      // Add in a bunch of dummy markers for testing
      var dummyMarkers = [
        [51.5182, -0.057163],
        [51.5760, -0.137163],
        [51.5672, -0.067163],
        [51.5480, -0.060163],
        [51.4860, -0.040163],
        [51.5252, -0.060163],
        [51.5169, -0.072163],
        [51.5163, -0.057163],
      ];

      $.each(dummyMarkers, function (indexInArray, latlng) {
        L.marker(latlng).addTo(_map).bindPopup(`
          <form>
          <h3>Eos odit qui odio molestiae eum ab dolor sit.</h3>
          <p>Enim itaque harum ut aut sed aut et voluptas. Reiciendis et quia voluptate fuga recusandae sequi optio voluptas. Harum vitae alias consequatur ratione. Natus sapiente totam voluptas. Dolor ea qui culpa quo ratione vel.</p>
          </form>
          <a href="new-discussion.html?autofill"><button class="button primary">Start discussion on this</button></a>
        `
        ).on('click', function () {
          // Do something
        });
      });


    },


    // Page-specific initialisation
    newDiscussion: function () {
      // For testing, if submitted with autofill param in URL, autofill.
      if (cyclescapeui.getUrlParameter('autofill')) {
        $('#title').val('Eos odit qui odio molestiae eum ab dolor sit.');
        $('#description').val('Enim itaque harum ut aut sed aut et voluptas. Reiciendis et quia voluptate fuga recusandae sequi optio voluptas. Harum vitae alias consequatur ratione. Natus sapiente totam voluptas. Dolor ea qui culpa quo ratione vel.');
      }

      // Initialise tinymce
      tinymce.init({
        selector: 'textarea',
        plugins: 'autoresize',
        statusbar: false,
        menubar: false,
        skin: (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'oxide-dark' : 'oxide'),
        content_css: (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default')
      });

    },

    getUrlParameter: function (sParam) {
      var sPageURL = window.location.search.substring(1),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

      for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
          return sParameterName[1] === undefined ? true : decodeURIComponent(sParameterName[1]);
        }
      }
      return false;
    },


    // Page-specific initialisation
    profile: function () {
      $('#submit-message').on('click', function (event) {
        event.preventDefault()
        // !TODO Add APi call
        $('#messageModal').modal('toggle');

        var myToastEl = document.getElementById('toast')
        var myToast = bootstrap.Toast.getOrCreateInstance(myToastEl) // Returns a Bootstrap toast instance
        myToast.show();

      });
    },


    // Geocode
    getNearestPoint: function (lon, lat, callback) {
      var apiCallUrl = CONSTANTS.geocoder.csBaseUrl + 'nearestpoint?key=' + CONSTANTS.geocoder.apiKey + '&lonlat=' + lon + ',' + lat;
      $.ajax({
        type: "GET",
        url: apiCallUrl,
        success: function (response) {
          callback(response);
        }
      });
    },


    setMarker: function (latLng) {
      _addIdeaMarker.setLatLng(latLng).update();
    },


    setName: function (locationName) {
      $('.location-name').html('<i class="fas fa-fw fa-map-pin"></i> ' + locationName);
    },


    // Set discussion internal toggle
    setDiscussionsView: function (desiredUl) {
      $('.main-content>ul').addClass("hidden")
      $('.main-content>ul.' + desiredUl).removeClass("hidden");

      if (desiredUl == 'deadlines') {
        $('.side-content').addClass("hidden")
      } else if ($(window).width() > 768) {
        $('.side-content').removeClass("hidden")
      } else {
        $('.side-content').addClass("hidden")
      }
    },


    // Returns the ordinal of an inputted number
    getOrdinal: function (number) {
      if (number == 1) {
        return 'st'
      } else if (number == 2) {
        return 'nd'
      } else if (number == 3) {
        return 'rd'
      } else {
        return 'th'
      }
    },


    // Iterate through ul.deadlines and add ordinal to the date numbers
    setDeadlinesOrdinal: function () {
      $.each($('ul.deadlines .date h3'), function (indexInArray, day) {
        $(day).text($(day).text() + cyclescapeui.getOrdinal($(day).text()))
      });

    },


    // Function to provide the default notification click behaviour
    setDefaultNotificationClickBehaviour: function () {
      // Slide up the ride notification on click
      $('.notification').on('click', function () {
        // If there is a queue of 'fx', we dequeue the current notification immediately, rather than waiting for the delay
        $('.notification').dequeue();
        $('.notification').slideUp('slow');
      });
    },

    initFavourites: function() {
      $(".favourite:not([data-fav='1'])").on('click', function (event) {
        var $this = $(this)
        event.preventDefault();

        $this.toggleClass('animate__heartBeat');
        var type
        if ($this.hasClass("favourited")) {
          type = "DELETE"
        } else {
          type = "POST"
        }
        $.ajax({ url: $this.data('url'), type: type })
      })
      $(".favourite").attr("data-fav", "1")
    },
  };
}(jQuery))

$(function () {
  cyclescapeui.initialise(document.body.classList[0])
})
