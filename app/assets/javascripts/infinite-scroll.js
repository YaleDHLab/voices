var $container = $(".masonry-container");
$container.infinitescroll({
  navSelector: "#next-page",
  nextSelector: "#next-page a",
  itemSelector: ".masonry-item",
  loading: {
    finishedMsg: "There are no more images to display",
    img: "/images/voices-logo.svg"
  }
}, function(newElements) {
  var $newElems = $(newElements);
  $container.masonry('appended', $newElements)
});  


