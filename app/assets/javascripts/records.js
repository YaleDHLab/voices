$(window).ready(function() {

  /***
  * initialize the datetimepicker, then create a listener 
  ***/

  $('#datetimepicker1').datetimepicker({
    format: "MM/DD/YYYY"
  });

  /***
  * add listener to update styles in record#show if viewport is too
  * narrow to display record title and buttons in one line
  ***/

  // store element widths, as these wont' change
  var recordTitleWidth = $("h3").width();
  var editDeleteButtonContainerWidth = $(".edit-delete-button-container").width();

  var restyleRecordShow = function() {
    var overImageRowWidth = $(".over-image-row").width();

    if (recordTitleWidth + editDeleteButtonContainerWidth + 40 >= overImageRowWidth) {
      // center both the record title and the edit and delete buttons
      var recordTitlePadding = (overImageRowWidth - recordTitleWidth) / 2;
      $(".record-title").css("width", "100%");
      $(".record-title").css("text-align", "center");

      $(".edit-delete-button-container").css("margin-top", "0px");
      $(".edit-delete-button-container").css("float", "none");
      $(".edit-delete-button-container").css("display", "block");
      $(".edit-delete-button-container").css("margin", "0 auto");
      $(".edit-delete-button-container").css("margin-bottom", "12px");
    } else {
      // restore original styles
      $(".record-title").css("padding-left", "");
      $(".record-title").css("display", "inline-block");
      $(".record-title").css("width", "");
      $(".record-title").css("text-align", "left");

      $(".edit-delete-button-container").css("margin-top", "31px");
      $(".edit-delete-button-container").css("float", "right");
      $(".edit-delete-button-container").css("display", "inline-block");
      $(".edit-delete-button-container").css("margin-bottom", "0px");
    }
  };

  restyleRecordShow();

  $(window).on("resize", function() {
    restyleRecordShow();
  })

});