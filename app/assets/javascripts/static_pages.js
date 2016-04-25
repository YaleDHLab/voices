$(document).on('ready', function() {
  // if browser doesn't support svg's, provide a fallback png
  jQuery(function(){
    var svg = !!('createElementNS' in document && document.createElementNS('http://www.w3.org/2000/svg','svg').createSVGRect);
    if (!svg){
      jQuery('body').addClass('no-svg');
      jQuery('img').each(function(){
        var $this = jQuery(this);
        var fp = $this.attr('src').split(".");
        var ext = fp.pop();
        if(ext.toLowerCase() == 'svg'){
          if($this.attr('data-svg-fallback') !== undefined){
            $this.attr('src', $this.attr('data-svg-fallback'));
            $this.removeAttr('data-svg-fallback');
          }else{
            $this.attr('src', fp.join('.')+'.png');
          }
        }
      });
    }else{ jQuery('body').addClass('svg'); }
  });

  // on document load, add listener for click of any 
  // child element in #text-overlay
  $("#text-overlay").children().on("click", function(el) {
    console.log(el.target);
  });

});