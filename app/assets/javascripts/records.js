// helper to set the currently selected file in the form
$(document).ready(function() {

  // when user clicks the file upload button, 
  // change the html of the placeholder box
  $("#custom-file-upload").on("change", function() {
    updatePlaceholderBox( $(this) );
  });

  var updatePlaceholderBox = function(thisContext) {
    $("#placeholder-box").html( thisContext.val().split("/").pop().split("\\").pop() );
  };
});