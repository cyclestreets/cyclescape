// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//= require constants
//= require jquery
//= require intersection-observer/intersection-observer
//= require rails-ujs
//= require jquery.selectboxes
//= require jquery.extentions
//= require jquery-ui/autocomplete
//= require jquery-ui/datepicker
//= require jquery-ui/dialog
//= require jquery-ui/slider
//= require cocoon
//= require js-cookie/src/js.cookie
//= require timeago
//= require tinymce
//= require tinymce_init
//= require leaflet
//= require leaflet-search
//= require leaflet-draw
//= require leaflet-layerjson
//= require superbly-tagfield.min
//= require map_display
//= require knockout
//= require slick-carousel
//= require jquery.tagsinput
//= require tags
//= require jquery-ui-sliderAccess
//= require jquery-ui-timepicker-addon.min
//= require jqcloud
//= require social
//= require location_preset
//= require leaflet_draw_override
//= require cropperjs/dist/cropper
//= require image_edit
//= require ajax_file_upload
//= require street_view
//= require popper
//= require bootstrap
//= require new_ui
//= require tooltip

import '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'
import UiController from 'controllers/ui-controller'
import PollOptionsController from 'controllers/poll-options-controller'
import MapLayerToggleController from 'controllers/map-layer-toggle-controller'
import DateTimePickerController from 'controllers/date-time-picker-controller'
import PmCountController from 'controllers/pm-count-controller'
import LibraryMessageController from 'controllers/library-message-controller'

// Start Stimulus and register controllers
const application = Application.start()
application.register('ui', UiController)
application.register('poll-options', PollOptionsController)
application.register('map-layer-toggle', MapLayerToggleController)
application.register('date-time-picker', DateTimePickerController)
application.register('pm-count', PmCountController)
application.register('library-message', LibraryMessageController)
Turbo.session.drive = false
