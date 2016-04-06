// helper to set the currently selected file in the form
$(document).ready(function() {

  /***
  * ensure the gray-background div height fills the remaining space
  ***/

  var calculateBackgroundHeight = function() {
    return $(document).height() - $("#header").height() - $("#footer").height() - $(".small-banner-image-container").height() - $(".record-details-top").height();
  };

  $(".gray-background").height( calculateBackgroundHeight() );

  $(window).resize(function() {
    $(".gray-background").height( calculateBackgroundHeight() );
  });

  /***
  * when user clicks the file upload button, change the html of the placeholder box
  ***/

  $("#custom-file-upload").on("change", function() {
    updatePlaceholderBox( $(this) );
  });

  var updatePlaceholderBox = function(thisContext) {
    $("#placeholder-box").html( thisContext.val().split("/").pop().split("\\").pop() );
  };
});

