$(document).on('ready', function() {
  // on document load, add listener for click of any 
  // child element in #text-overlay
  $("#text-overlay").children().on("click", function(el) {
    console.log(el.target);
  });

  var colorRange = ["#c3c3c3", "#8d8d8d",
  "#848484", "#6f6f6f", "#646464", "#545454"]

  var generateRandomNumber = function(min, max) {
    return Math.random() * (max - min) + min;
  };

  var rgb2hex = function rgb2hex(rgb) {
    if (/^#[0-9A-F]{6}$/i.test(rgb)) return rgb;

    rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
    function hex(x) {
        return ("0" + parseInt(x).toString(16)).slice(-2);
    }
    return "#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
  };

  var updateWordColors = function() {
    try {
      var idToTarget = "word-number-" + Math.round( generateRandomNumber(0, 900) );
      var currentTarget = document.getElementById( idToTarget );
      var currentTargetRgbColor = getComputedStyle( currentTarget, "").getPropertyValue('color');
      var currentColor = rgb2hex( currentTargetRgbColor );
      var currentColorIndex = colorRange.indexOf(currentColor);

      if (currentColorIndex == colorRange[colorRange.length] - 1) {
        currentTarget.style.color = colorRange[colorRange.length - 2];
      }

      else if (currentColorIndex == 0) {
        currentTarget.style.color = colorRange[1];
      }

      else {
        var randomVariable = generateRandomNumber(0, 1);
        // specify the probability the word will increase in color
        if (randomVariable > .5 ) {
          currentTarget.style.color = colorRange[currentColorIndex + 1];
        }
        else {
          currentTarget.style.color = colorRange[currentColorIndex - 1];
        }
      };
    
    } catch (TypeError) {}

    };

  // additionally, update the colors of words dynamically
  window.setInterval(function(){
    updateWordColors();
  }, 100);

});