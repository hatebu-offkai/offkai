$(function(){
    console.log("onload");
    loadYoutube(
      mouseCustom
    );

    var scroll_flag = 0;
    $(window).scroll(function () {
      if (scroll_flag === 0) {
        startMatrix();
        hatebuButtonShower();
        scroll_flag = 1;
      }
    });

    $('.destroy').click(function() {
      destroy();
    });

    var rainbowElementsCount = $('li').length;
    for (var i=0; i<rainbowElementsCount; i++) {
      $('li').eq(i).kabuki().rainbow();
    }
  }
);
