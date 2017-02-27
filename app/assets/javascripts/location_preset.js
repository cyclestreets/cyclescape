$(document).ready(function() {
  if ($('.user_location #user_location').length > 0) {
    var map, startSearchControl, destSearchControl, startSearchEl, destSearchEl, startLocation, userLocationPlaceholder,
      destLocation, constituencyLabelsEl, areaAroundEl, routeEl, wardLabelsEl, groupLabelsEl, userLocationEl,
      locationEl, locationChange;
    map = new LeafletMap($('.map-data').data('center'), $('.map-data').data('opts'));
    startSearchControl = map.addSearchControl(
      {autoCollapse: false, collapsed: false, circleLocation: false,
        startLocation: true, textPlaceholder: 'Start/home location'}
    );
    destSearchControl = map.addSearchControl(
      {autoCollapse: false, collapsed: false, circleLocation: false,
        destLocation: true, textPlaceholder: 'Regular destination (optional)'}
    );
    $('.search-input').attr('size', 25);
    startSearchEl = startSearchControl.getContainer();
    destSearchEl = destSearchControl.getContainer();
    userLocationEl = $('#user_location');
    userLocationEl.append(startSearchEl);
    $('#dest_location').append(destSearchEl);
    areaAroundEl = $('.location-presets #area_around_me');
    routeEl = $('.location-presets #route');
    groupLabelsEl = $('.group-labels');
    wardLabelsEl = $('.ward-labels');
    constituencyLabelsEl = $('.constituency-labels');
    var nosIssues = $('#nos_issues');
    var updateNosIssues = function(issues){
      nosIssues.html('&nbsp;' + issues.features.length + '&nbsp;');
    };
    var date = new Date();
    date.setMonth(date.getMonth() - 3);
    locationEl = $('[id$="_loc_json"]');
    locationChange = function(){
      var geoCollection = $(locationEl).val();
      if(geoCollection === '') {
        updateNosIssues({features: []});
        return;
      }
      $.ajax({
        type: 'POST',
        url: '/api/issues',
        // jshint camelcase: false
        data: { geo_collection: geoCollection, start_date: date.toJSON() },
        dataType: jsonpTransportRequired() ? 'jsonp' : void 0,
        timeout: 10000,
        success: updateNosIssues
      });
    };

    locationEl.change(locationChange);
    locationChange();
    var drawFeature = function(e) {
      if(e.target.checked) {
        map.drawFeatureId($(e.target).data('geo'), $(e.target).prop('id'));
      } else {
        map.drawFeatureId(null, $(e.target).prop('id'));
      }
    };

    var jsonToCheckboxes = function(json, labelsEl, nameFn, idFn) {
      if (!nameFn) {
        nameFn = function(feature) { return feature.properties.name; };
      }
      if (!idFn) {
        idFn = function(feature){
          var hash = 0, name = nameFn(feature);
          if (name.length === 0) return hash;
          for (var i = 0; i < name.length; i++) {
            var char = name.charCodeAt(i);
            hash = ((hash<<5)-hash)+char;
            hash = hash & hash; // Convert to 32bit integer
          }
          return hash;
        };
      }

      labelsEl.find('label').hide();
      labelsEl.find('input:checked').parent().show();

      for (var f = 0, featuresLen = json.features.length; f < featuresLen; f++) {
        var feature = json.features[f], id = idFn(feature), name = nameFn(feature),
          checkbox = labelsEl.find('#' + id);
        if (checkbox[0]) {
          checkbox.parent().show();
        } else {
          var newEl = $('<label class="location-presets"><input type="checkbox" name="' +
            id + '" id="' + id +'">' + name + '<br></label>').appendTo(labelsEl);
          newEl.find('input').data('geo', feature.geometry).change(drawFeature);
        }
      }
    };

    var parser = document.createElement('a');

    var newGroupJson = function(groupJson) {
      var idFn = function(group) {
        parser.href = group.properties.url;
        return parser.hostname.split('.')[0];
      };
      jsonToCheckboxes(groupJson, groupLabelsEl, function(fe) { return fe.properties.title; }, idFn);
    };

    var newConstituencyJson = function(json) {
      jsonToCheckboxes(json, constituencyLabelsEl);
    };

    var newWardJson = function(json) {
      jsonToCheckboxes(json, wardLabelsEl);
    };

    var moveAjax = [];
    var mapMove = function(){
      for(var ma = 0, maLength = moveAjax.length; ma < maLength; ma++){
        moveAjax[ma].abort();
      }
      moveAjax = [];

      var params = {
        // jshint camelcase: false
        data: { bbox: map.map.getBounds().toBBoxString(), per_page: 4 },
        dataType: jsonpTransportRequired() ? 'jsonp' : void 0,
        timeout: 10000
      };

      params.url = '/api/groups';
      params.success = newGroupJson;
      moveAjax.push($.ajax(params));

      params.url = '/api/constituencies';
      params.success = newConstituencyJson;
      moveAjax.push($.ajax(params));

      params.url = '/api/wards';
      params.success = newWardJson;
      moveAjax.push($.ajax(params));
    };

    mapMove();

    map.map.on('move', mapMove);

    startSearchControl.on('search_locationfound', function(e) {
      areaAroundEl.prop('disabled', false);
      startLocation = [e.latlng.lat, e.latlng.lng];
      if (userLocationPlaceholder){
        userLocationEl.find('input').attr('placeholder', userLocationPlaceholder);
      }
    });

    destSearchControl.on('search_locationfound', function(e) {
      if (startLocation) {
        routeEl.prop('disabled', false);
      }
      destLocation = [e.latlng.lat, e.latlng.lng];
    });

    areaAroundEl.change(function(e) {
      if(e.target.checked) {
        map.drawCircle(startLocation);
      } else {
        map.drawCircle();
      }
    });

    routeEl.change(function(e) {
      if(e.target.checked) {
        var params = [
          { name: 'key', value: window.CONSTANTS.geocoder.apiKey },
          { name: 'itinerarypoints', value: startLocation[1] + ',' +
            startLocation[0] + '|' + destLocation[1] + ',' + destLocation[0] },
          { name: 'plan', value: 'balanced'}
        ];
        $.ajax({
          url: 'https://www.cyclestreets.net/api/journey.json?' + $.param(params),
          dataType: jsonpTransportRequired() ? 'jsonp' : void 0,
          timeout: 10000,
          success: function(json) {
            var route = L.polyline([]), points, p, pLen;
            points = json.marker[0]['@attributes'].coordinates.split(' ');
            for (p = 1, pLen = points.length; p < pLen; p++) {
              route.addLatLng(points[p].split(',').reverse());
            }
            map.drawFeatureId(route.toGeoJSON(), 'route');
          }
        });
      } else {
        map.drawFeatureId(null, 'route');
      }
    });

    if (navigator.geolocation) {
      var updateLocation = function(pos){
        var lat = pos.coords.latitude, lng = pos.coords.longitude;
        areaAroundEl.prop('disabled', false);
        startLocation = [lat, lng];
        map.map.setView([lat, lng], 13);
        userLocationPlaceholder = userLocationEl.find('input').attr('placeholder');
        userLocationEl.find('input').attr('placeholder', userLocationEl.data('currentLocation'));
      };
      $('#current_location').css('display','inline-block').click(function() {
        navigator.geolocation.getCurrentPosition(updateLocation);
      });
    }
  }
});
