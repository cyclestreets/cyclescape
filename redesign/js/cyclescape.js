/*jslint browser: true, white: true, single: true, for: true, long: true */
/*global $, jQuery, layerviewer, routing, EXIF, findEXIFinHEIC, vex, osm2geo, alert, console, window */

var cyclescapeui = (function ($) {

	'use strict';

	// Default settings
	var _settings =
	{
		disactivateCloseSearch: false,
	};

	var _actions = [
		'discussions'
	];

	// Class properties
	var _currentWizardPage = 0; // Current page on progress div pages i.e. account creation
	var _pageScroll = 0; // Save page scroll when opening an overlay on mobile


	return {

		// Main function
		initialise: function (config, page = false) {
			// Merge the configuration into the settings
			$.each(_settings, function (setting, value) {
				if (config.hasOwnProperty(setting)) {
					_settings[setting] = config[setting];
				}
			});

			// Initialise the UI
			cyclescapeui.navBar();
			cyclescapeui.searchBar();
			cyclescapeui.autocomplete();
			cyclescapeui.tagsAutocomplete();
			cyclescapeui.geocoder();
			cyclescapeui.sideContent();
			cyclescapeui.mapControls();
			cyclescapeui.popovers();
			cyclescapeui.segmentedControl();
			cyclescapeui.contentToggle();
			cyclescapeui.enableWizard();


			// Initialise each section
			if (_actions.includes(page)) {
				cyclescapeui[page]();
			};
		},


		/*
		 * Nav bar functions
		 */
		navBar: function () {
			// Open nav on click
			$('#hamburger').on('click', function () {
				cyclescapeui.openNav();
			});

			// Enable normal "click" close
			$('body').on('click', function (event) {
				if ($('nav').hasClass('open')) {
					cyclescapeui.closeNav();
				}
			});

			// Enable swipe-to-close
			$('nav').on('swipeleft', function () {
				if ($('nav').hasClass('open')) {
					cyclescapeui.closeNav();
				}
			});

			// Listen for resize, if hamburger is set to hidden but window expands to desktop
			$(window).resize(function () {
				if ($(window).width() > 1000) {
					$('nav').show();
				} else {
					$('nav').hide();
				}
			});

			$(document).on('keydown', function (event) {
				if (event.key == "Escape") {
					if ($('nav').hasClass('open')) {
						cyclescapeui.closeNav();
					}
				}
			});
		},


		// Open the nav bar
		openNav: function () {
			// Add shades
			$('#shade').removeClass('white').fadeIn('fast');

			// Slide the nav out from the left
			$('nav').show('slide', { direction: 'left' }, 300, function () {
				$('nav').addClass('open');
			})
		},


		// Close the nav bar
		closeNav: function () {
			$('#shade').fadeOut();
			$('nav').removeClass('open');
			$('nav').hide("slide", { direction: "left" }, 300);
		},


		// Set up the search bar
		searchBar: function () {

			// Open the search bar if clicking the icon
			$('#search').on('click', function () {
				if (!$('#search').hasClass('expanded')) {
					$('#search i').toggleClass('fa-search').toggleClass('fa-times-circle');
					$('#search').addClass('expanded');


					$('#search input').focus();
					_settings.disactivateCloseSearch = true;
					setTimeout(function () {
						_settings.disactivateCloseSearch = false;
					}, 100);
				}
			});

			// Close search box on escape key		
			document.onkeydown = function (evt) {
				evt = evt || window.event;
				var isEscape = false;
				if ("key" in evt) {
					isEscape = (evt.key === "Escape" || evt.key === "Esc");
				} else {
					isEscape = (evt.keyCode === 27);
				}
				if (isEscape) {
					cyclescapeui.closeSearchBar();
				}
			};

			// Close the search bar if clicking on the x
			$('#search fa-times-circle').on('click', function () {
				cyclescapeui.closeSearchBar();
			});

			// Close the search bar if clicking outside it
			$('body').on('click', function () {
				cyclescapeui.closeSearchBar();
			});
		},


		// Close search bar
		closeSearchBar: function () {
			if ($('#search').hasClass('expanded') && _settings.disactivateCloseSearch === false) {
				$('#search').removeClass('expanded')
				$('#search i').toggleClass('fa-search').toggleClass('fa-times-circle');
			}
		},


		// Enable geocoder animations
		geocoder: function () {
			$('.geocoder i').on('click', function () {
				$('.geocoder').toggleClass('expanded');
				$('.geocoder input').focus()
			});
		},


		// Enable autocomplete
		// !TODO add real data
		autocomplete: function () {
			var availableTags = [
				"ActionScript",
				"AppleScript",
				"Asp",
				"BASIC",
				"C",
				"C++",
				"Clojure",
				"COBOL",
				"ColdFusion",
				"Erlang",
				"Fortran",
				"Groovy",
				"Haskell",
				"Java",
				"JavaScript",
				"Lisp",
				"Perl",
				"PHP",
				"Python",
				"Ruby",
				"Scala",
				"Scheme"
			];
			$(".geocoder input").autocomplete({
				appendTo: "#geocoder",
				source: availableTags
			});
		},


		// Enable autocomplete
		// !TODO add real data
		tagsAutocomplete: function () {
			var availableTags = [
				"ActionScript",
				"AppleScript",
				"Asp",
				"BASIC",
				"C",
				"C++",
				"Clojure",
				"COBOL",
				"ColdFusion",
				"Erlang",
				"Fortran",
				"Groovy",
				"Haskell",
				"Java",
				"JavaScript",
				"Lisp",
				"Perl",
				"PHP",
				"Python",
				"Ruby",
				"Scala",
				"Scheme"
			];
			$("input.group-autocomplete").autocomplete({
				appendTo: ".group-search",
				source: availableTags
			});
		},


		// Enable Bootstrap popovers
		popovers: function () {
			var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
			var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
				return new bootstrap.Popover(popoverTriggerEl)
			})
		},


		// Set up mobile side-content view
		sideContent: function () {

			// Handle filter button
			$('.show-side-content').on('click', function () {
				if ($('.side-content').hasClass('visible')) {
					$('.show-side-content').html('Filter <i class="fas fa-fw fa-filter"></i>');
					$('#shade').fadeOut('fast');
					$('.side-content').removeClass('visible').hide();
					window.scrollTo(0, _pageScroll);
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
				if ($(window).width() > 750) {
					$('.side-content').show();
				} else {
					$('.side-content').hide();
				}
			});
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


		// Set up mobile side-content view
		mapControls: function () {

			// Handle filter button
			$('.show-map-controls').on('click', function () {
				if ($('.map-controls').hasClass('visible')) {
					$('.show-map-controls').html('Map controls <i class="fas fa-fw fa-filter"></i>').css('z-index', '97');
					$('#shade').fadeOut('fast');
					$('.map-controls').removeClass('visible').hide();
				} else {
					$('.show-map-controls').html('Done <i class="fas fa-fw fa-check"></i>').css('z-index', '99');
					$('#shade').addClass('white').fadeIn('fast');
					$('.map-controls').addClass('visible').show()
					window.scrollTo(0, 0);
				}
			});

			// If we have hidden the side content and window resizes, CSS doesn't kick it - override
			$(window).on('resize', function () {
				if ($(window).width() > 750) {
					$('.side-content').show();
				} else {
					$('.side-content').hide();
				}
			});
		},


		// Segmented control
		segmentedControl: function () {
			// Constants
			const SEGMENTED_CONTROL_BASE_SELECTOR = ".ios-segmented-control";
			const SEGMENTED_CONTROL_INDIVIDUAL_SEGMENT_SELECTOR = ".ios-segmented-control .option input";
			const SEGMENTED_CONTROL_BACKGROUND_PILL_SELECTOR = ".ios-segmented-control .selection";

			forEachElement(SEGMENTED_CONTROL_BASE_SELECTOR, (elem) => {
				elem.addEventListener('change', updatePillPosition);
			});
			window.addEventListener('resize',
				updatePillPosition
			); // Prevent pill from detaching from element when window resized. Becuase this is rare I haven't bothered with throttling the event

			function updatePillPosition() {
				forEachElement(SEGMENTED_CONTROL_INDIVIDUAL_SEGMENT_SELECTOR, (elem, index) => {
					if (elem.checked) moveBackgroundPillToElement(elem, index);
				});
			}

			function moveBackgroundPillToElement(elem, index) {
				document.querySelector(SEGMENTED_CONTROL_BACKGROUND_PILL_SELECTOR).style.transform = 'translateX(' + (elem.offsetWidth * index) + 'px)';
			}

			// Helper functions
			function forEachElement(className, fn) {
				Array.from(document.querySelectorAll(className)).forEach(fn);
			}

			// Watch window width to swap text for icons
			$(window).on('resize', function () {
				cyclescapeui.setSegmentedControlIcons();
			});

			// Adjust icons on startup, too
			cyclescapeui.setSegmentedControlIcons();
		},

		// Function to set icons and text on segmented control
		setSegmentedControlIcons: function () {
			if ($(window).width() > 1200) {
				// Show text
				$.each($('.ios-segmented-control.adjustable-icons .option label span'), function (index, span) {
					$(span).text(' ' + $(span).data('text'));
				})
			} else {
				// Show icons
				var icon;
				$.each($('.ios-segmented-control.adjustable-icons .option label span'), function (index, span) {
					icon = $("<span />", {
						html: 'Spanned <i class="fas fa-fw fa-angle-double-left"></i>',
						class: "myClass"
					});
					$(span).empty().html("<i class='fa " + $(span).data('icon') + "></i>");
				})
			}
		},


		// Searches for a content-view toggle and displays on the checked toggle
		changeToSelectedView: function () {
			var desiredDivId = '#content-' + $('input[name=content-view]:checked', '#content-view').val()
			$('.content-wrapper').hide();
			$(desiredDivId).show();
		},


		// Enable content toggles between main-content divs on the same page
		// If a toggle named content-view is found, corresponding divs (named content-#id) will be shown dynamically
		contentToggle: function () {
			// At page launch, hide all but default content div
			if ($('#content-view').length) {
				cyclescapeui.changeToSelectedView();
			}

			// Trigger when the segmented control changes
			$('#content-view').on('change', function () {
				cyclescapeui.changeToSelectedView();
			});
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
		discussions: function () {
			$('.ios-segmented-control div.option').on('click', function () {
				var desiredUl = $(this).find('input').prop('id');
				cyclescapeui.setDiscussionsView(desiredUl);
			});

			// At launch, set to first div
			var firstDiv = $('.ios-segmented-control input').first().prop('id');
			cyclescapeui.setDiscussionsView(firstDiv);

			// Set the ordinal of the deadline date
			cyclescapeui.setDeadlinesOrdinal();
		},


		// Set discussion internal toggle
		setDiscussionsView: function (desiredUl) {
			$('.main-content>ul').hide();
			$('.main-content>ul.' + desiredUl).show();
		},


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

	};
}(jQuery));
