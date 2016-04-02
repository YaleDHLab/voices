// on document load, add listener for click of any 
// child element in #text-overlay
$(document).ready(function() {
  $("#text-overlay").children().on("click", function(el) {
    console.log(el.target);
  });
});