$(function(){
    console.log("onload");
    loadYoutube(
      mouseCustom
    );

    var startRainbow = function(){
      var elms = ["li", "a", "h1", "h2", "h3", "span","marquee"];
      _.each(elms, function(els){
        $(els).each(function(){
          var el = $(this);
          if(!el.hasClass("skip")){
            $(this).kabuki().rainbow()
          }
        });
      });
    };

    var scroll_flag = 0;
    $(window).scroll(function () {
      if (scroll_flag === 0) {
        startMatrix();
        hatebuButtonShower();
        scroll_flag = 1;
      }
    });

    var mousemove_flag = 0;
    $('html').mousemove(function () {
      if (mousemove_flag === 0) {
        mousemove_flag = 1;
        setTimeout(startRainbow, 1500);
      }
    });

  }
);
