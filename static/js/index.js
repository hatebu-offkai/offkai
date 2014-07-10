$(function(){
    console.log("onload");
    loadYoutube(
      mouseCustom
    );
    hatebuButtonShower();

    $('.destroy').click(function() {
      destroy();
    });

    var rainbowElementsCount = $('li').length;
    for (var i=0; i<rainbowElementsCount; i++) {
      $('li').eq(i).kabuki().rainbow();
    }
  }
);
