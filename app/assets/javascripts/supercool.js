/*
 * read more
 */
function readMore(elem, trig, h) {
  elem.toggleClass(function() {
    if ($(this).is('.open')) {
      $(this).height(h).removeClass('open');
      trig.removeClass('active');
      $('span', trig).text('read more');
      return 'closed';
    } else {
      $(this).height('auto').removeClass('closed');
      trig.addClass('active');
      $('span', trig).text('close');
      return 'open';
    }
  });
}

$(function(){
  /*
   * Hide/show on read more button
   */
  $('p.readmore').addClass('closed');
  //clicks
  $('.read-more-box').live('click', function(e){
    e.preventDefault();
    var h = '';
    if ($(this).attr('rel')) {
      // attribute exists
      h = $(this).attr('rel');
    } else {
      // attribute does not exist
      h = 80;
    }

    $readmore = $(this).prev('.readmore');
    readMore($readmore, $(this), h);
  });

  /*
   * NOT BRILLIANT - resource list and checks
   */
  $('#resource-list li').live('click', function(e){
    e.preventDefault();
    if ($(this).hasClass('open')) {
      $(this).removeClass('open').addClass('closed');
      $('p, .btn-grey', $(this)).hide();
    } else {
      $(this).removeClass('closed').addClass('open');
      $('p, .btn-grey', $(this)).show();
    }
  });
  $('.check').click(function(){
    $(this).toggleClass('checked');
  });

  /*
   * group selector
   */
  // hide on hover of my account
  $('li.my-account').hover(function(e){
    if ($('.group-selector').hasClass('open')) {
      $('.group-selector').removeClass('open').addClass('closed');
    }
  });
  // clicks
  $('.group-selector').live('click', function(e){
    e.preventDefault();
    if ($(this).hasClass('open')) {
      $(this).removeClass('open').addClass('closed');
    } else {
      $(this).removeClass('closed').addClass('open');
    }
  });

  /*
   * Tagging shiz
   */
  var tags = ['Obstruction', 'Cycle Path', 'Car Parking Violation', 'Destination', 'Roadworks'];

    // Initialize Demo 2
  $("#issue-tags").superblyTagField({
      allowNewTags: true,
      showTagsNumber: 10,
      addItemOnBlur: true,
      tags: tags
  });
});
