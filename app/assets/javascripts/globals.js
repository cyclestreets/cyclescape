// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//= require constants
//= require jquery
//= require rails-ujs
//= require jquery.selectboxes
//= require jquery.extentions
//= require jquery-ui/effect
//= require jquery-ui/effect-slide
//= require jquery-ui/autocomplete
//= require jquery-ui/datepicker
//= require jquery-ui/dialog
//= require jquery-ui/slider
//= require jquery-ui/tabs
//= require cocoon
//= require @benmajor/jquery-touch-events/src/jquery.mobile-events
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

bootstrap.Tooltip.Default.allowList['*'] = ['*']
bootstrap.Tooltip.Default.sanitizeFn = (content) => content
bootstrap.Tooltip.Default.sanitize = false

bootstrap.Popover.Default.allowList['*'] = ['*']
bootstrap.Popover.Default.sanitizeFn = (content) => content
bootstrap.Popover.Default.sanitize = false
