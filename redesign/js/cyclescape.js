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
		'discussions',
		'index',
		'discussion',
		'newIdea',
		'profile',
		'newDiscussion',
		'topic'
	];

	// Class properties
	var _currentWizardPage = 0; // Current page on progress div pages i.e. account creation
	var _pageScroll = 0; // Save page scroll when opening an overlay on mobile
	var _sideContentHtml = '';
	const isIOSSafari = !!window.navigator.userAgent.match(/Version\/[\d\.]+.*Safari/);
	var _scrollProgress = 0; // Track scroll progress to hide filter button when we are low down

	var _map = null; // Leaflet map
	var _addIdeaMarker = null; // Save the Leaflet marker in newIdea
	var _selectedAttachment = null; // Selected attachment in Discussion view


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
			cyclescapeui.filterable();
			cyclescapeui.uploadPreview();
			cyclescapeui.autofocus();
			cyclescapeui.tagsAutocomplete();
			cyclescapeui.geocoder();
			cyclescapeui.sideContent();
			cyclescapeui.mapControls();
			cyclescapeui.popovers();
			cyclescapeui.toasts();
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
				if (event.target.tagName != 'LI') {
					if ($('nav').hasClass('open')) {
						cyclescapeui.closeNav();
					}
				}
			});

			// Enable swipe-to-close
			$('nav').on('swipeleft', function () {
				if ($('nav').hasClass('open')) {
					cyclescapeui.closeNav();
				}
			});

			// Listen for resize, if hamburger is set to hidden but window expands to desktop
			$(window).on('resize', function () {
				if (isIOSSafari) { return; }
				if ($(window).width() > 1000) {
					$('nav').show();
				} else {
					$('nav').hide();
				}
			});

			// Listen for escape key to close menu
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
			// Close group change popover
			var exampleTriggerEl = document.getElementById('group-popover')
			try {
				var popover = bootstrap.Popover.getOrCreateInstance(exampleTriggerEl) // Returns a Bootstrap popover instance
				popover.hide();
			} catch (e) {
				// No popover found
			}

			// Close menu
			$('#shade').fadeOut();
			$('nav').removeClass('open');
			$('nav').hide("slide", { direction: "left" }, 300);
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


		// Set up the search bar
		searchBar: function () {

			// Initialise results
			var data = [
				{ label: 'Discussion', value: 'discussion.html' },
				{ label: 'Discussions', value: 'discussions.html' },
				{ label: 'Browse issues', value: 'browse-topics.html' },
				{ label: 'Profile', value: 'profile.html' }
			];

			$('#search input').autocomplete({
				appendTo: '#search',
				source: data,
				focus: function (event, ui) {
					$(event.target).val(ui.item.label);
					return false;
				},
				select: function (event, ui) {
					$(event.target).val(ui.item.label);
					window.location = ui.item.value;
					return false;
				}
			});

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
			$('body').on('click', function (event) {
				if (event.target.localName != 'input') {
					cyclescapeui.closeSearchBar();
				}
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
				$('.geocoder i').toggleClass('fa-search').toggleClass('fa-times');
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
				"Cambridge Cycling Campaign",
				"Leeds Cycling Campaign",
				"London Cycling Campaign",
				"Oxford Cycling Campaign",
				"Durham Cycling Campaign",
				"Manchester Cycling Campaign",
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
					$('.main-content').css('position', 'unset')
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
			$('.main-content').css('position', 'relative');
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
					$('.main-content').css('position', 'unset')
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
			$('.main-content').css('position', 'relative');
			$('.show-map-controls').html(buttonLabel);
			$('#shade').fadeOut('fast');
			$('.map-controls').removeClass('visible').hide();
			window.scrollTo(0, _pageScroll);
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

			// Remember each page's segmented control position
			$('#content-view').on('change', function () {
				var divId = '#content-' + $('input[name=content-view]:checked', '#content-view').val();
				var pageId = 'cyclescape-' + $('body').attr('class');
				Cookies.set(pageId, divId, { expires: 7 })
			});

			// On startup, if we have a stored cookie for page view, change to that view
			var pageId = 'cyclescape-' + $('body').attr('class');
			var savedCookie = Cookies.get(pageId);
			if (savedCookie !== undefined) {
				// Uncheck all #content inputs
				$.each($('input[name=content-view]'), function (indexInArray, input) {
					$(input).attr('checked', false);
				});

				// Check the div referred to in the cookie
				// Cookie = #content-list
				var desiredId = savedCookie.split('-').pop();
				$('input#' + desiredId).attr('checked', true).trigger('change');
				updatePillPosition();
			}

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
			var desiredDivId = '#content-' + $('input[name=content-view]:checked', '#content-view').val();
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
		discussions: function () {
			$('.ios-segmented-control div.option').on('click', function () {
				var desiredUl = $(this).find('input').prop('id');
				cyclescapeui.setDiscussionsView(desiredUl);
			});

			// Save the side content HTML for toggling on/off
			_sideContentHtml = $('.side-content').html()

			// At launch, set to first div
			var firstDiv = $('.ios-segmented-control input').first().prop('id');
			cyclescapeui.setDiscussionsView(firstDiv);

			// Set the ordinal of the deadline date
			cyclescapeui.setDeadlinesOrdinal();

			// Ensure redirect to group management
			$('ul.discussions ul.tags li').on('click', function (event) {
				event.preventDefault();
				window.location.href = "generic-content.html";
			});

			// Clicking on a star toggles favourite status
			// !TODO Implement API call
			$('ul.discussions .favourite').on('click', function (event) {
				$(this).toggleClass('favourited');
				event.preventDefault();

				if ($(this).hasClass('favourited')) {
					$(this).toggleClass('animate__heartBeat');
					// Add API call	
				}
			});
		},


		// Page-specific initialisation
		index: function () {
			var data = [
				{ label: 'Cambridge Cycling Campaign', value: 'group.html' },
				{ label: 'Oxford Cycling Campaign', value: 'group.html' },
				{ label: 'Durham Cycling Campaign', value: 'group.html' },
				{ label: 'Manchester Cycling Campaign', value: 'group.html' },
				{ label: 'Cardiff Cycling Campaign', value: 'group.html' },
			];
			$('#groups').autocomplete({
				source: data,
				focus: function (event, ui) {
					$(event.target).val(ui.item.label);
					return false;
				},
				select: function (event, ui) {
					$(event.target).val(ui.item.label);
					window.location = ui.item.value;
					return false;
				}
			});
		},


		// Page-specific initialisation
		topic: function () {
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
			L.tileLayer(`https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=${config.mapboxglAccessToken}`, {
				attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
				maxZoom: 18,
				id: 'mapbox/streets-v11',
				tileSize: 512,
				zoomOffset: -1,
				accessToken: config.mapboxglAccessToken
			}).addTo(_map);
		},


		// Page-specific initialisation
		discussion: function () {
			var addContentModal = new bootstrap.Modal(document.getElementById('addContentModal'), {})

			// Clicking on a star toggles favourite status
			// !TODO Implement API call
			$('.favourite').on('click', function (event) {
				$(this).toggleClass('favourited');
				event.preventDefault();

				if ($(this).hasClass('favourited')) {
					$(this).toggleClass('animate__heartBeat');
					// Add API call	
				}
			});

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
				var quotedText = $(this).parent('.post-actions').siblings('.flex').find('.post').first().text();
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

			// Demo for autosave appearing every now and then
			setInterval(function () {
				$('.autosave').fadeIn().css('display', 'inline-block');
				setTimeout(function () {
					$('.autosave').fadeOut();
				}, 1500);
			}, 4000);


			// Clicking the load more button spins the spinner
			$('li.load-more').on('click', function () {
				$(this).find('p i').fadeIn().css('display', 'inline-block').addClass('fa-spin');
			});

			// Hide the filter button when we are at the bottom of the page (i.e. in reply reply box)
			$(window).on('scroll', function (e) {
				var scrollTop = $(window).scrollTop();
				var docHeight = $(document).height();
				var winHeight = $(window).height();
				var scrollPercent = (scrollTop) / (docHeight - winHeight);
				_scrollProgress = Math.round(scrollPercent * 100);
				cyclescapeui.updateScrollProgress ();
			});
		},

		
		// Hide side content button if we are at the bottom of the page
		updateScrollProgress: function () {
			if (_scrollProgress > 80) {
				$('.show-side-content').fadeOut();
			} else {
				$('.show-side-content').fadeIn();
			}
		},


		// Page-specific initialisation
		newIdea: function () {
			// Initialise map
			_map = L.map('ideamap', {
				zoomControl: false,
				tap: false // c.f. https://stackoverflow.com/questions/65030691/click-event-fires-twice-for-item-inside-a-loop
			}).setView([51.505, -0.09], 13);

			// Add zoom control to bottom right
			L.control.zoom({
				position: 'bottomright'
			}).addTo(_map);

			// Load in a tile layer
			L.tileLayer(`https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=${config.mapboxglAccessToken}`, {
				attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
				maxZoom: 18,
				id: 'mapbox/streets-v11',
				tileSize: 512,
				zoomOffset: -1,
				accessToken: config.mapboxglAccessToken
			}).addTo(_map);

			// On click, add a marker
			_map.on('click', function (e) {
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
					<img src="https://www.cyclestreets.net/location/1/cyclestreets1-size300.jpg" />
					</form>
					<div class="post-actions">
						<a href="new-discussion.html?autofill" title="Create a private discussion in your group about this idea"><button class="button primary">Start discussion on this</button></a>
						<button class="like" title="Upvote this to show your support">
							<i class="fas fa-fw fa-thumbs-up"></i> 3
						</button>
					</div>
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

			//  The Location row should fade out and disappear if Administration or General chat are selected. 
			var hideLocationCategories = ['administration', 'general'];
			$('form .radio').on('change', function () {
				var selectedRadioButton = $('form .radio input[name="category"]:checked').val();
				if (hideLocationCategories.includes(selectedRadioButton)) {
					$('.locationControls').fadeOut();
				} else {
					$('.locationControls').fadeIn();
				}
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
			var apiCallUrl = config.apiBaseUrl + '/v2/nearestpoint?key=' + config.apiKey + '&lonlat=' + lon + ',' + lat;
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
			$('.main-content>ul').hide();
			$('.main-content>ul.' + desiredUl).show();

			if (desiredUl == 'deadlines') {
				$('.side-content').html('');
			} else {
				$('.side-content').html(_sideContentHtml);
				if ($(window).width() > 768) {
					$('.side-content').show();
				}
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

	};
}(jQuery));
