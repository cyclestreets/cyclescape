/*
 * Simple Tabs
 */
function simpleTabs(elem)
{
	var tc = elem.attr('href');
	if(!$(tc).hasClass('open'))
	{
		//hide/show tab content
		$('.tab-nav ul li a.active').removeClass('active');
		$(elem).addClass('active');
		$('.tab.open').removeClass('open').hide();
		$(tc).addClass('open').show();
	}
}

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
	 * simple tabs
	 */
	// check if hash in the url and set up open
	// tab or default to the first one
	if(window.location.hash != '')
	{
		//strip out default active states
		$('.tab-nav ul li a.active').removeClass('active');
		//get hash from url
		var hash = window.location.hash;
		$('.tab-nav ul').find("li a[href='"+hash+"']").addClass('active');
		//make the hashed tab active and hide all others
		var simpleTabActive = $('.tab-nav ul li a.active').attr('href');
		$(simpleTabActive).addClass('open');
		$('.tab').not('.open').hide();
	}
	else
	{
		//make initial tab active and hide other tabs
		var simpleTabActive = $('.tab-nav ul li a.active').attr('href');
		$(simpleTabActive).addClass('open');
		$('.tab').not('.open').hide();
	}
	//for clicks
	$(".tab-nav ul li a").click(function(e){
		window.location.hash = $(this).attr('href');
		e.preventDefault();
		simpleTabs($(this));
	});

	/*
	 * Hide/show on read more button
	 */
	$('p.readmore').addClass('closed');
	//clicks
	$('.intro .read-more-box').live('click', function(e){
		e.preventDefault();
		$readmore = $(this).prev('.readmore');
		readMore($readmore, $(this), 80);
	});

	$('#issue-intro .read-more-box').live('click', function(e){
		e.preventDefault();
		$readmore = $(this).prev('.readmore');
		readMore($readmore, $(this), 180);
	});

	$('.thread .read-more-box').live('click', function(e){
		e.preventDefault();
		$readmore = $(this).prev('.readmore');
		readMore($readmore, $(this), 80);
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
        tags: tags
    });
});