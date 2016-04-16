$(document).ready(function() {

  /***
  * function that takes as input an integer {0,1} and 
  * sets the boolean slider's class and toggle position appropriately
  ***/

  var setBooleanSliderClass = function(i) {
    // update the class value indicator
    $(".boolean-slider-knob").removeClass("user-selection-0");
    $(".boolean-slider-knob").removeClass("user-selection-1");
    $(".boolean-slider-knob").addClass("user-selection-" + String(i) );

    // update the toggle position
    if (String(i) == "1") {
      $(".boolean-slider-knob").animate({
        marginLeft: "17px"
      }, 350);
    } else {
      $(".boolean-slider-knob").animate({
        marginLeft: "0px"
      }, 350);
    };
  };

  /***
  * define a function that takes as input {0,1}
  * and uses that input to set the text in #boolean-slider-text
  ***/

  var setBooleanFieldText = function(i) {

    // update the boolean-slider-text div
    if (String(i) == "1") {
      $("#boolean-slider-text").html("YES");
    } else {
      $("#boolean-slider-text").html("NO");
    };
  };


  /***
  * function that uses the slider to set the rails form value
  ***/

  var setBooleanRailsField = function(i) {
    $("input#record_include_name").val(i);
  };
  

  /***
  * function that toggles the slider using class attributes
  ***/

  var toggleBooleanSlider = function() {
    if ( $(".boolean-slider-knob").hasClass("user-selection-0") ) {
      setBooleanSliderClass(1);
      setBooleanFieldText(1);
      setBooleanRailsField(1);
    } else {
      setBooleanSliderClass(0);
      setBooleanFieldText(0);
      setBooleanRailsField(0);
    };
  };

  /***
  * define a function that uses the current boolean value
  * to set the #boolean-slider-text and rails field
  ***/

  var setBooleanChangeListener = function() {
    // add an onchange event that updates the rails form and the
    // #boolean-slider-text div when user toggles the slider
    $(".boolean-slider-knob").on("mousedown", function() {
      toggleBooleanSlider();
    });
  };

  setBooleanChangeListener();

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
