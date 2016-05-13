$(window).ready(function() {

  /***
  * initialize the datetimepicker, then create a listener 
  ***/

  $('#datetimepicker1').datetimepicker({
    format: "MM/DD/YYYY"
  });

  /***
  * add listener to launch modal if user clicks button to delete record
  ***/

  $("#delete-record-button").on("click", function() {
    $('#delete-record-modal').modal();
  });

  /***
  * add listener to update styles in record#show if viewport is too
  * narrow to display record title and buttons in one line
  ***/

  // store element widths, as these wont' change
  var recordTitleWidth = $("h3").width();
  var modifyRecordButtonWidth = $(".modify-record-button").width();

  var restyleRecordShow = function() {
    var overImageRowWidth = $(".over-image-row").width();

    console.log(recordTitleWidth, modifyRecordButtonWidth, overImageRowWidth);

    if (recordTitleWidth + modifyRecordButtonWidth + 40 >= overImageRowWidth) {
      
      // center both the record title and the edit/delete/report record buttons
      $(".record-title").css({
        "width": "100%", 
        "text-align": "center"
      });

      $(".edit-delete-button-container").css({
        "float": "none",
        "display": "block"
      });

      $(".modify-record-button").css({
        "margin-top": "0px",
        "float": "none",
        "display": "block",
        "margin-bottom": "12px",
        "left": "50%",
        "margin-left": 0 - (modifyRecordButtonWidth / 2)
      });

    } else {
      // restore original styles
      $(".record-title").css({
        "padding-left": "",
        "display": "inline-block",
        "width": "",
        "text-align": "left"
      });

      $(".edit-delete-button-container").css({
        "float": "right",
        "display": "inline-block"
      });

      $(".modify-record-button").css({
        "margin": "",
        "margin-top": "30px",
        "float": "right",
        "display": "inline-block",
        "margin-left": "0px",
        "margin-bottom": "0px",
        "left": "0px"
      });

    }
  };

  restyleRecordShow();

  $(window).on("resize", function() {
    restyleRecordShow();
  })

});