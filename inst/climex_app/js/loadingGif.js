(function($) {
  /* if the animation is started, show the Gif */
  $('#animation-buttonDrawAnimation').bind( 'click', function( event ){
    $( '#busy-loadingGif' ).css( 'visibility', 'visible' );
    $( '#busy-loadingGif' ).css( 'width', '100%' );
  });
  /* if the animation is started, show the Gif */
  $('#leaflet-buttonDrawMarkers').bind( 'click', function( event ){
    $( '#busy-loadingGif' ).css( 'visibility', 'visible' );
    $( '#busy-loadingGif' ).css( 'width', '100%' );
  });
  /* since the shiny server should be idle after sending the pictures hide it*/
  $(document).on( 'shiny:idle', function( event ){
    $( '#busy-loadingGif' ).css( 'visibility', 'hidden' );
    $( '#busy-loadingGif' ).css( 'width', '0%' );
  });
  // Transforming the scale of the return level slider in the leatlet map
  // to a logarithmic scale.
  $( '#leaflet-sliderReturnLevel' ).data( 'ionRangeSlider' ).update({
    'prettify': function( exponent ) { return( Math.round( Math.pow( 10, exponent ) ) ); }
  });
})(jQuery);
