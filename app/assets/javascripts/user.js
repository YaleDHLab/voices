$(window).load(function() {

  $('.grid').masonry({
    // set itemSelector so .grid-sizer is not used in layout
    itemSelector: '.grid-item',
    // use element for option
    columnWidth: 1,
    percentPosition: true
  });

  $('.grid').masonry('reloadItems');

  // apply a border box to all images
  var body = document.getElementsByClassName("container")[0];
  var tags = body.getElementsByTagName("a");
  var total = tags.length;
  for ( i = 0; i < total; i++ ) {
    tags[i].style.border = '1px solid darkgray';
    tags[i].style.boxShadow = "1px 1px 5px #888888";
  };
})

// use jquery to ensure the gray-background div height fills the remaining page height
$(document).ready(function() {
  
  var calculateBackgroundHeight = function() {
    return $(document).height() - $("#header").height() - $("#footer").height() - $(".small-banner-image-container").height();
  };

  $(".gray-background").height( calculateBackgroundHeight() );

  $(window).resize(function() {
    $(".gray-background").height( calculateBackgroundHeight() );
  });
});